part of 'login_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponse response;

  LoginSuccess({required this.response});
}

class LoginFailure extends LoginState {
  final Object? error;

  LoginFailure({this.error});
}
