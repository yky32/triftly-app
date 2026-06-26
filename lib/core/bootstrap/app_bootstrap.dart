import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../environment.dart';
import '../repositories/hive_trip_repository.dart';
import '../repositories/local_auth_repository.dart';
import '../repositories/supabase_auth_repository.dart';
import '../repositories/supabase_trip_sync.dart';
import '../services/profile_preferences.dart';
import '../services/user_session.dart';

/// Initializes Hive, auth, trips, and optional Supabase.
class AppBootstrap {
  AppBootstrap._();

  static late final ProfilePreferences profilePreferences;
  static late final UserSession userSession;
  static late final HiveTripRepository tripRepository;

  /// True when [Supabase.initialize] completed successfully this session.
  static bool supabaseReady = false;

  static Future<void> initialize() async {
    profilePreferences = await ProfilePreferences.initialize();

    if (Environment.hasSupabase) {
      try {
        final url = Environment.supabaseUrl.trim();
        final key = Environment.supabaseClientKey.trim();
        await Supabase.initialize(url: url, publishableKey: key).timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw TimeoutException('Supabase.initialize timed out'),
        );
        supabaseReady = true;
        if (kDebugMode) {
          debugPrint('Supabase ready: $url');
        }
      } catch (error, stack) {
        supabaseReady = false;
        developer.log(
          'Supabase init failed — continuing in offline mode',
          name: 'triftly.bootstrap',
          error: error,
          stackTrace: stack,
        );
      }
    } else if (kDebugMode) {
      debugPrint(
        'Supabase OFF — add secrets to env/.env.local, then restart. '
        'Sign-in uses local guest mode only.',
      );
    }

    final localAuth = LocalAuthRepository(profilePreferences);
    final auth = SupabaseAuthRepository(
      preferences: profilePreferences,
      localFallback: localAuth,
    );
    await auth.initialize();

    userSession = UserSession(auth: auth, preferences: profilePreferences);

    final supabaseSync = supabaseReady ? SupabaseTripSync() : null;
    tripRepository = await HiveTripRepository.bootstrap(supabaseSync: supabaseSync);

    auth.authStateChanges.listen((user) async {
      if (user != null && !user.id.startsWith('local-')) {
        try {
          await tripRepository.migrateLocalTripsToCloud(user);
          await tripRepository.pullFromSupabase(user.id);
        } catch (error, stack) {
          developer.log(
            'Cloud sync after sign-in failed',
            name: 'triftly.bootstrap',
            error: error,
            stackTrace: stack,
          );
        }
      }
    });
  }
}

class AppScope extends InheritedWidget {
  const AppScope({
    required this.session,
    required this.tripRepository,
    required super.child,
    super.key,
  });

  final UserSession session;
  final HiveTripRepository tripRepository;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      session != oldWidget.session || tripRepository != oldWidget.tripRepository;
}
