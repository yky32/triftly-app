import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../environment.dart';
import '../models/user.dart';
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
  final _controller = StreamController<User?>.broadcast();
  User? _user;

  bool get _useSupabase =>
      Environment.hasSupabase && supabase.Supabase.instance.isInitialized;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _user;

  @override
  bool get isSignedIn => _user != null;

  @override
  Future<void> initialize() async {
    if (!_useSupabase) {
      _user = null;
      _controller.add(null);
      return;
    }

    final session = supabase.Supabase.instance.client.auth.currentSession;
    if (session?.user != null) {
      _user = _userFromAuth(session!.user);
      unawaited(_upsertUserSafe(_user!));
      _controller.add(_user);
    }
    supabase.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final authUser = data.session?.user;
      _user = authUser == null ? null : _userFromAuth(authUser);
      _controller.add(_user);
    });
  }

  Future<void> _upsertUser(User user) async {
    if (!_useSupabase) return;
    await supabase.Supabase.instance.client.from('users').upsert(user.toMap());
  }

  Future<void> _upsertUserSafe(User user) async {
    try {
      await _upsertUser(user);
    } catch (_) {
      // Do not block startup on profile sync.
    }
  }

  User _userFromAuth(supabase.User authUser) => User(
        id: authUser.id,
        displayName: authUser.userMetadata?['display_name'] as String? ??
            authUser.email?.split('@').first ??
            'Traveler',
        email: authUser.email,
        defaultCurrency: _preferences.defaultCurrency,
        updatedAt: DateTime.now(),
      );

  @override
  Future<User?> signInWithEmailOtp(String email) async {
    if (!_useSupabase) return _local.signInWithEmailOtp(email);
    await supabase.Supabase.instance.client.auth.signInWithOtp(email: email);
    return null;
  }

  @override
  Future<void> verifyEmailOtp({required String email, required String token}) async {
    if (!_useSupabase) return _local.verifyEmailOtp(email: email, token: token);
    final response = await supabase.Supabase.instance.client.auth.verifyOTP(
      type: supabase.OtpType.email,
      email: email,
      token: token,
    );
    final authUser = response.user;
    if (authUser != null) {
      _user = _userFromAuth(authUser);
      await _upsertUser(_user!);
      _controller.add(_user);
    }
  }

  @override
  Future<void> signOut() async {
    if (!_useSupabase) return _local.signOut();
    await supabase.Supabase.instance.client.auth.signOut();
    _user = null;
    _controller.add(null);
  }

  @override
  Future<void> updateUser(User user) async {
    _user = user;
    await _preferences.setDefaultCurrency(user.defaultCurrency);
    if (_useSupabase) {
      await supabase.Supabase.instance.client.from('users').upsert(user.toMap());
    }
    _controller.add(_user);
  }
}
