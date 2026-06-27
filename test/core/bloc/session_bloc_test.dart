import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triftly/core/bloc/session/session_bloc.dart';
import 'package:triftly/core/models/user.dart';
import 'package:triftly/core/repositories/auth_repository.dart';
import 'package:triftly/core/services/auth_state_stream.dart';
import 'package:triftly/core/services/profile_preferences.dart';

void main() {
  group('replayAuthState', () {
    test('emits current user before stream events', () async {
      final controller = StreamController<User?>.broadcast();
      final user = User(
        id: '22222222-2222-4222-8222-222222222222',
        displayName: 'Wayne',
        email: 'wayne@example.com',
        updatedAt: DateTime(2026, 1, 1),
      );

      final events = <User?>[];
      final sub = replayAuthState(user, controller.stream).listen(events.add);

      await Future<void>.delayed(Duration.zero);
      expect(events, [user]);

      final other = user.copyWith(displayName: 'Updated');
      controller.add(other);
      await Future<void>.delayed(Duration.zero);
      expect(events, [user, other]);

      await sub.cancel();
      await controller.close();
    });
  });

  group('SessionBloc cold start', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await ProfilePreferences.initialize();
    });

    test('restores cloud user when auth emitted before subscribe', () async {
      final auth = _FakeAuthRepository();
      final cloudUser = User(
        id: '2f48d84b-fc85-4abc-82da-b6c10194bed5',
        displayName: 'Wayne Yu',
        email: 'wayne@example.com',
        updatedAt: DateTime(2026, 1, 1),
      );

      await auth.restoreSession(cloudUser);

      final bloc = SessionBloc(
        auth: auth,
        preferences: ProfilePreferences.instance,
      );

      expect(bloc.state.isCloudSignedIn, isTrue);
      expect(bloc.state.user?.email, 'wayne@example.com');
      await bloc.close();
    });

    test('sign out clears cloud user from session state', () async {
      final auth = _FakeAuthRepository();
      final cloudUser = User(
        id: '2f48d84b-fc85-4abc-82da-b6c10194bed5',
        displayName: 'Wayne Yu',
        email: 'wayne@example.com',
        updatedAt: DateTime(2026, 1, 1),
      );
      await auth.restoreSession(cloudUser);

      final bloc = SessionBloc(
        auth: auth,
        preferences: ProfilePreferences.instance,
      );

      expect(bloc.state.isCloudSignedIn, isTrue);
      await bloc.signOut();

      expect(bloc.state.user, isNull);
      expect(bloc.state.isCloudSignedIn, isFalse);
      await bloc.close();
    });

    blocTest<SessionBloc, SessionState>(
      'SessionDefaultCurrencyChanged updates fallback for guest',
      build: () => SessionBloc(
        auth: _FakeAuthRepository(),
        preferences: ProfilePreferences.instance,
      ),
      act: (bloc) => bloc.add(const SessionDefaultCurrencyChanged('EUR')),
      verify: (bloc) => expect(bloc.state.defaultCurrency, 'EUR'),
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();
  User? _user;

  @override
  User? get currentUser => _user;

  @override
  bool get isSignedIn => _user != null;

  @override
  Stream<User?> get authStateChanges =>
      replayAuthState(_user, _controller.stream);

  Future<void> restoreSession(User user) async {
    _user = user;
    await initialize();
  }

  @override
  Future<void> initialize() async {
    if (_user != null) _controller.add(_user);
  }

  @override
  Future<User?> signInWithEmailOtp(String email) async => null;

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  @override
  Future<void> updateUser(User user) async {
    _user = user;
    _controller.add(_user);
  }

  @override
  Future<void> verifyEmailOtp({required String email, required String token}) async {}
}
