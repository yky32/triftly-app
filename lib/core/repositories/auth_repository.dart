import '../models/user.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  bool get isSignedIn => currentUser != null;

  Future<void> initialize();
  Future<User?> signInWithEmailOtp(String email);
  Future<void> verifyEmailOtp({required String email, required String token});
  Future<void> signOut();
  Future<void> updateUser(User user);
}
