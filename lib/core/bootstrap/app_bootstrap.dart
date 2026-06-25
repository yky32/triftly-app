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

  static Future<void> initialize() async {
    profilePreferences = await ProfilePreferences.initialize();

    if (Environment.hasSupabase) {
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        publishableKey: Environment.supabaseClientKey,
      );
    }

    final localAuth = LocalAuthRepository(profilePreferences);
    final auth = SupabaseAuthRepository(
      preferences: profilePreferences,
      localFallback: localAuth,
    );
    await auth.initialize();

    userSession = UserSession(auth: auth, preferences: profilePreferences);

    final supabaseSync = Environment.hasSupabase ? SupabaseTripSync() : null;
    tripRepository = await HiveTripRepository.bootstrap(supabaseSync: supabaseSync);

    auth.authStateChanges.listen((user) async {
      if (user != null && !user.id.startsWith('local-')) {
        await tripRepository.pullFromSupabase(user.id);
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
