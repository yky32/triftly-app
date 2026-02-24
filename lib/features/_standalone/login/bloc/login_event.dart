part of 'login_bloc.dart';

abstract class LoginEvent {}

class LoginRequest extends LoginEvent {
  final String email;
  final String credentials;

  LoginRequest({
    required this.email,
    required this.credentials,
  });
}

class LogoutRequest extends LoginEvent {}
