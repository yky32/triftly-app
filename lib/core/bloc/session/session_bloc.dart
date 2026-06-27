import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/cloud_trip_sync.dart';
import '../../services/profile_preferences.dart';

part 'session_event.dart';
part 'session_state.dart';

/// App-wide auth + profile preferences for signed-in UI.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({
    required AuthRepository auth,
    required ProfilePreferences preferences,
  })  : _auth = auth,
        _preferences = preferences,
        super(SessionState.initial(auth.currentUser, preferences.defaultCurrency)) {
    on<SessionAuthUserChanged>(_onAuthUserChanged);
    on<SessionDefaultCurrencyChanged>(_onDefaultCurrencyChanged);
    on<SessionDisplayNameChanged>(_onDisplayNameChanged);
    on<SessionSignOutRequested>(_onSignOutRequested);

    _authSubscription = _auth.authStateChanges.listen((user) {
      add(SessionAuthUserChanged(user));
    });
  }

  final AuthRepository _auth;
  final ProfilePreferences _preferences;
  late final StreamSubscription<User?> _authSubscription;

  Stream<User?> get authStateChanges => _auth.authStateChanges;

  Future<User?> signInWithEmail(String email) => _auth.signInWithEmailOtp(email);

  Future<void> signInWithGoogle() => _auth.signInWithGoogle();

  Future<void> verifyEmailOtp({required String email, required String token}) =>
      _auth.verifyEmailOtp(email: email, token: token);

  Future<void> signOut() async {
    add(const SessionSignOutRequested());
    await stream.firstWhere((state) => state.user == null);
  }

  Future<void> updateDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    final user = state.user;
    if (trimmed.isEmpty || user == null || trimmed == user.displayName) return;

    await _auth.updateUser(user.copyWith(
      displayName: trimmed,
      updatedAt: DateTime.now(),
    ));
  }

  void _onAuthUserChanged(SessionAuthUserChanged event, Emitter<SessionState> emit) {
    // Auth stream is source of truth — do not use copyWith(user: null); it cannot clear user.
    emit(SessionState(user: event.user, fallbackCurrency: state.fallbackCurrency));
  }

  Future<void> _onDefaultCurrencyChanged(
    SessionDefaultCurrencyChanged event,
    Emitter<SessionState> emit,
  ) async {
    await _preferences.setDefaultCurrency(event.code);
    final user = state.user;
    if (user != null) {
      await _auth.updateUser(user.copyWith(
        defaultCurrency: event.code,
        updatedAt: DateTime.now(),
      ));
      return;
    }
    emit(state.copyWith(fallbackCurrency: event.code));
  }

  Future<void> _onDisplayNameChanged(
    SessionDisplayNameChanged event,
    Emitter<SessionState> emit,
  ) async {
    await updateDisplayName(event.displayName);
  }

  Future<void> _onSignOutRequested(
    SessionSignOutRequested event,
    Emitter<SessionState> emit,
  ) async {
    await _auth.signOut();
    emit(SessionState(user: null, fallbackCurrency: state.fallbackCurrency));
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
