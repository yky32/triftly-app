import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sample_app/router/app_page.dart';
import 'package:sample_app/router/app_router.dart';
import 'package:sample_app/core/network/logger.dart';
import 'package:sample_app/core/network/storage.dart';

class ApiInterceptor extends InterceptorsWrapper {
  final StorageService _storageService = StorageService();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final method = options.method;
    final uri = options.uri;
    final data = options.data;
    options.headers["Content-Type"] = "application/json";

    if (options.headers['Authorization'] == null) {
      final tokenInfo = await _storageService.getTokenInfo();
      final accessToken = tokenInfo?['accessToken'];

      if (accessToken != null) {
        // Add the access token to the request headers
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    // d("\n\n--------------------------------------------------------------------------------------------------------");
    if (method == 'GET') {
      LoggerUtil.d(
          "✈️ REQUEST[$method] => PATH: $uri \n Headers: ${options.headers}");
    } else {
      LoggerUtil.d(
          "✈️ REQUEST[$method] => PATH: $uri \n Headers: ${options.headers}");
      try {
        LoggerUtil.d(
            "✈️ REQUEST[$method] => PATH: $uri \n DATA: ${jsonEncode(data)}");
      } catch (e) {
        LoggerUtil.d("✈️ REQUEST[$method] => PATH: $uri \n DATA: $data");
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final statusCode = response.statusCode;
    final uri = response.requestOptions.uri;
    if (kDebugMode) {
      LoggerUtil.d(response.data);
    }
    final data = jsonEncode(response.data);
    LoggerUtil.d("✅ RESPONSE[$statusCode] => PATH: $uri\n DATA: $data");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final res = err.response?.data;
    final uri = err.requestOptions.path;
    if (kDebugMode) {
      var data = "";
      try {
        data = jsonEncode(err.response?.data);
      } catch (e) {
        LoggerUtil.e(e);
      }
      LoggerUtil.e("⚠️ ERROR[$statusCode] => PATH: $uri\n DATA: $data");
    }
    // Handle session time out
    if (res['httpStatus'] == 'UNAUTHORIZED') {
      LoggerUtil.e('UNAUTHORIZED');
      AppRouter.router.go(
        AppPage.login.path,
      );
    }

    super.onError(err, handler);
  }
}
