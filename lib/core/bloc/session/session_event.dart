part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

final class SessionAuthUserChanged extends SessionEvent {
  const SessionAuthUserChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user];
}

final class SessionDefaultCurrencyChanged extends SessionEvent {
  const SessionDefaultCurrencyChanged(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class SessionDisplayNameChanged extends SessionEvent {
  const SessionDisplayNameChanged(this.displayName);

  final String displayName;

  @override
  List<Object?> get props => [displayName];
}

final class SessionSignOutRequested extends SessionEvent {
  const SessionSignOutRequested();
}
