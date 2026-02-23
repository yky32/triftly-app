import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sample_app/core/dto/common_response.dart';
import 'package:sample_app/core/dto/login_response.dart';
import 'package:sample_app/core/network/api_interceptor.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: dotenv.env['API_BASE_URL']!,
            validateStatus: (status) => status != null && status < 400,
          ),
        )..interceptors.addAll(
            [ApiInterceptor()],
          );

  //Login
  Future<LoginResponse> login(String username, String credentials) async {
    final response = await _dio.post(
      '/auth/user',
      data: {
        'username': username,
        'credentials': credentials,
      },
      options: Options(
        headers: {'Authorization': dotenv.env['API_BASE_TOKEN']!},
      ),
    );
    final CommonResponse commonResponse = CommonResponse.fromMap(response.data);
    if (commonResponse.httpStatus == "OK") {
      return LoginResponse.fromMap(response.data['data']);
    } else {
      throw Exception('Error occurred while login: ${commonResponse.message}');
    }
  }
}
