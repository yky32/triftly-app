import '../models/user_profile.dart';

abstract class AuthRepository {
  Stream<UserProfile?> get authStateChanges;
  UserProfile? get currentUser;
  bool get isSignedIn => currentUser != null;

  Future<void> initialize();
  Future<UserProfile?> signInWithEmailOtp(String email);
  Future<void> verifyEmailOtp({required String email, required String token});
  Future<void> signOut();
  Future<void> updateProfile(UserProfile profile);
}
