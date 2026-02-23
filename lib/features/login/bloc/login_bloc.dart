import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/dto/login_response.dart';
import 'package:triftly/core/network//api_client.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginRequest>(_handleLoginRequest);
    on<LogoutRequest>(_handleLogoutRequest);
  }

  void _handleLogoutRequest(LogoutRequest event, Emitter<LoginState> emit) {
    emit(LoginInitial());
  }

  void _handleLoginRequest(LoginRequest event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      final response = await ApiClient().login(event.email, event.credentials);
      emit(
        LoginSuccess(response: response),
      );
    } catch (e) {
      emit(
        LoginFailure(error: e),
      );
    }
  }
}
