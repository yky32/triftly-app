import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../environment.dart';
import '../models/user_profile.dart';
import '../services/profile_preferences.dart';
import 'auth_repository.dart';
import 'local_auth_repository.dart';

/// Supabase auth with local fallback when not configured.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required ProfilePreferences preferences,
    required LocalAuthRepository localFallback,
  })  : _preferences = preferences,
        _local = localFallback;

  final ProfilePreferences _preferences;
  final LocalAuthRepository _local;
  final _controller = StreamController<UserProfile?>.broadcast();
  UserProfile? _user;

  bool get _useSupabase =>
      Environment.hasSupabase && Supabase.instance.isInitialized;

  @override
  Stream<UserProfile?> get authStateChanges => _controller.stream;

  @override
  UserProfile? get currentUser => _user;

  @override
  bool get isSignedIn => _user != null;

  @override
  Future<void> initialize() async {
    if (!_useSupabase) {
      _user = null;
      _controller.add(null);
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session?.user != null) {
      _user = _profileFromUser(session!.user);
      _controller.add(_user);
    }
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      _user = user == null ? null : _profileFromUser(user);
      _controller.add(_user);
    });
  }

  UserProfile _profileFromUser(User user) => UserProfile(
        id: user.id,
        displayName: user.userMetadata?['display_name'] as String? ??
            user.email?.split('@').first ??
            'Traveler',
        email: user.email,
        defaultCurrency: _preferences.defaultCurrency,
        updatedAt: DateTime.now(),
      );

  @override
  Future<UserProfile?> signInWithEmailOtp(String email) async {
    if (!_useSupabase) return _local.signInWithEmailOtp(email);
    await Supabase.instance.client.auth.signInWithOtp(email: email);
    return null;
  }

  @override
  Future<void> verifyEmailOtp({required String email, required String token}) async {
    if (!_useSupabase) return _local.verifyEmailOtp(email: email, token: token);
    final response = await Supabase.instance.client.auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: token,
    );
    final user = response.user;
    if (user != null) {
      _user = _profileFromUser(user);
      _controller.add(_user);
    }
  }

  @override
  Future<void> signOut() async {
    if (!_useSupabase) return _local.signOut();
    await Supabase.instance.client.auth.signOut();
    _user = null;
    _controller.add(null);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    _user = profile;
    await _preferences.setDefaultCurrency(profile.defaultCurrency);
    if (_useSupabase) {
      await Supabase.instance.client.from('profiles').upsert(profile.toMap());
    }
    _controller.add(_user);
  }
}
