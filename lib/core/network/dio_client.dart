import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  late Dio dio;
  final FlutterSecureStorage storage;
  bool _isRefreshing = false;
  final List<Future<Response> Function(String)> _queuedRequests = [];

  DioClient({required this.storage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://10.0.2.2:3050",
        headers: {"Content-Type": "application/json"},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: "accessToken");
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains("/auth/refresh-token")) {
            final refreshToken = await storage.read(key: "refreshToken");
            if (refreshToken == null) {
              await _logout();
              return handler.reject(
                DioException(
                  requestOptions: e.requestOptions,
                  error: Exception("Session hết hạn. Vui lòng đăng nhập lại."),
                ),
              );
            }

            if (!_isRefreshing) {
              _isRefreshing = true;
              try {
                final refreshResponse = await dio.post("/auth/refresh", data: {
                  "refreshToken": refreshToken,
                });

                final newAccessToken = refreshResponse.data['accessToken'];
                await storage.write(key: "accessToken", value: newAccessToken);

                _isRefreshing = false;

                // Retry queued requests
                for (var callback in _queuedRequests) {
                  await callback(newAccessToken);
                }
                _queuedRequests.clear();

                // Retry request hiện tại
                final options = e.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccessToken';
                final cloneResponse = await dio.fetch(options);
                return handler.resolve(cloneResponse);
              } catch (_) {
                _isRefreshing = false;
                _queuedRequests.clear();
                await _logout();
                return handler.reject(
                  DioException(
                    requestOptions: e.requestOptions,
                    error: Exception("Session hết hạn. Vui lòng đăng nhập lại."),
                  ),
                );
              }
            } else {
              // queue request
              final completer = Completer<Response>();
              _queuedRequests.add((newToken) async {
                final options = e.requestOptions;
                options.headers['Authorization'] = 'Bearer $newToken';
                final response = await dio.fetch(options);
                completer.complete(response);
                return response;
              });
              final response = await completer.future;
              return handler.resolve(response);
            }
          }
          return handler.next(e);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<void> _logout() async {
    await storage.deleteAll();
  }
}
