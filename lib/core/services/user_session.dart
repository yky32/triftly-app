import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../services/profile_preferences.dart';

/// Auth state + local preferences exposed to the UI.
class UserSession extends ChangeNotifier {
  UserSession({
    required AuthRepository auth,
    required ProfilePreferences preferences,
  })  : _auth = auth,
        _preferences = preferences {
    _subscription = _auth.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final AuthRepository _auth;
  final ProfilePreferences _preferences;
  late final StreamSubscription<User?> _subscription;
  User? _user;

  User? get currentUser => _user;
  bool get isSignedIn => _user != null;
  String get defaultCurrency =>
      _user?.defaultCurrency ?? _preferences.defaultCurrency;

  Future<User?> signInWithEmail(String email) =>
      _auth.signInWithEmailOtp(email);

  Future<void> verifyEmailOtp({required String email, required String token}) =>
      _auth.verifyEmailOtp(email: email, token: token);

  Future<void> signOut() => _auth.signOut();

  Future<void> setDefaultCurrency(String code) async {
    await _preferences.setDefaultCurrency(code);
    if (_user != null) {
      await _auth.updateUser(_user!.copyWith(
        defaultCurrency: code,
        updatedAt: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class UserSessionScope extends InheritedNotifier<UserSession> {
  const UserSessionScope({
    required UserSession session,
    required super.child,
    super.key,
  }) : super(notifier: session);

  static UserSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<UserSessionScope>();
    assert(scope != null, 'UserSessionScope not found');
    return scope!.notifier!;
  }
}
