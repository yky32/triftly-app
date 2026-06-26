import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_deep_link_bridge.dart';
import '../auth/auth_debug_log.dart';
import '../bloc/cloud_sync/cloud_sync_bloc.dart';
import '../environment.dart';
import '../repositories/hive_trip_repository.dart';
import '../repositories/local_auth_repository.dart';
import '../repositories/cloud_trip_sync.dart';
import '../repositories/supabase_auth_repository.dart';
import '../repositories/supabase_trip_sync.dart';
import '../services/profile_preferences.dart';
import '../services/user_session.dart';
import '../sync/cloud_sync_reporter.dart';

/// Initializes Hive, auth, trips, and optional Supabase.
class AppBootstrap {
  AppBootstrap._();

  static late final ProfilePreferences profilePreferences;
  static late final UserSession userSession;
  static late final HiveTripRepository tripRepository;
  static late final CloudSyncReporterBridge cloudSyncReporter;
  static late final CloudSyncBloc cloudSyncBloc;

  /// True when [Supabase.initialize] completed successfully this session.
  static bool supabaseReady = false;

  static String? _lastCloudSyncUserId;
  static DateTime? _lastCloudSyncAt;

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
        await AuthDeepLinkBridge.install();
        if (kDebugMode) {
          authDebugLog('Supabase init completed → $url', kind: AuthLogKind.session);
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

    cloudSyncReporter = CloudSyncReporterBridge();
    final supabaseSync = supabaseReady
        ? SupabaseTripSync(syncReporter: cloudSyncReporter)
        : null;
    tripRepository = await HiveTripRepository.bootstrap(
      supabaseSync: supabaseSync,
      syncReporter: cloudSyncReporter,
    );
    cloudSyncBloc = CloudSyncBloc(
      userSession: userSession,
      syncReporter: cloudSyncReporter,
      tripRepository: tripRepository,
    );

    auth.authStateChanges.listen((user) async {
      if (user == null || !CloudTripSync.isCloudUserId(user.id)) return;

      final now = DateTime.now();
      if (_lastCloudSyncUserId == user.id &&
          _lastCloudSyncAt != null &&
          now.difference(_lastCloudSyncAt!) < const Duration(seconds: 10)) {
        return;
      }
      _lastCloudSyncUserId = user.id;
      _lastCloudSyncAt = now;

      authDebugLog('Cloud sync starting for ${user.email} (${user.id})', kind: AuthLogKind.sync);
      try {
        await CloudTripSync.syncForUser(
          user,
          tripRepository,
          syncReporter: cloudSyncReporter,
          migrateLocalTrips: true,
        );
        authDebugLog('Cloud sync finished for ${user.id}', kind: AuthLogKind.success);
      } catch (error, stack) {
        authDebugLog(
          'Cloud sync after sign-in failed',
          kind: AuthLogKind.error,
          error: error,
          stackTrace: stack,
        );
      }
    });

    final signedInUser = auth.currentUser;
    if (signedInUser != null && CloudTripSync.isCloudUserId(signedInUser.id)) {
      try {
        await CloudTripSync.syncForUser(
          signedInUser,
          tripRepository,
          syncReporter: cloudSyncReporter,
        );
      } catch (error, stack) {
        developer.log(
          'Cloud sync on startup failed',
          name: 'triftly.bootstrap',
          error: error,
          stackTrace: stack,
        );
      }
    }
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
