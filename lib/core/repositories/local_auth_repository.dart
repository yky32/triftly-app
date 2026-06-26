import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/profile_preferences.dart';
import 'auth_repository.dart';

/// Guest / local-only auth until Supabase is configured.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._preferences);

  final ProfilePreferences _preferences;
  final _controller = StreamController<User?>.broadcast();
  User? _user;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _user;

  @override
  bool get isSignedIn => _user != null;

  @override
  Future<void> initialize() async {}

  @override
  Future<User?> signInWithEmailOtp(String email) async {
    final user = User(
      id: 'local-${const Uuid().v4()}',
      displayName: email.split('@').first,
      email: email,
      defaultCurrency: _preferences.defaultCurrency,
      updatedAt: DateTime.now(),
    );
    _user = user;
    _controller.add(_user);
    return user;
  }

  @override
  Future<void> signInWithGoogle() async {
    throw UnsupportedError('Google sign-in requires Supabase configuration');
  }

  @override
  Future<void> verifyEmailOtp({required String email, required String token}) async {}

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  @override
  Future<void> updateUser(User user) async {
    _user = user;
    await _preferences.setDefaultCurrency(user.defaultCurrency);
    _controller.add(_user);
  }
}
