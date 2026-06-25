import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../services/profile_preferences.dart';
import 'auth_repository.dart';

/// Guest / local-only auth until Supabase is configured.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._preferences);

  final ProfilePreferences _preferences;
  final _controller = StreamController<UserProfile?>.broadcast();
  UserProfile? _user;

  @override
  Stream<UserProfile?> get authStateChanges => _controller.stream;

  @override
  UserProfile? get currentUser => _user;

  @override
  bool get isSignedIn => _user != null;

  @override
  Future<void> initialize() async {}

  @override
  Future<UserProfile?> signInWithEmailOtp(String email) async {
    final profile = UserProfile(
      id: 'local-${const Uuid().v4()}',
      displayName: email.split('@').first,
      email: email,
      defaultCurrency: _preferences.defaultCurrency,
      updatedAt: DateTime.now(),
    );
    _user = profile;
    _controller.add(_user);
    return profile;
  }

  @override
  Future<void> verifyEmailOtp({required String email, required String token}) async {}

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    _user = profile;
    await _preferences.setDefaultCurrency(profile.defaultCurrency);
    _controller.add(_user);
  }
}
