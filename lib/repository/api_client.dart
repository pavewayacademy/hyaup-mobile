import 'package:dio/dio.dart';

import 'auth.dart';

class ApiClient {
  final Dio dio = Dio();
  final AuthRepository _authRepository = AuthRepository();

  ApiClient() {
    dio.options.baseUrl = "http://0.0.0.0:8000";

    // Wire up the interceptor workflow
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Fetch the valid toekn (return cache or generates new one)
          final String? token = await _authRepository.getIdToken();

          // Attach token to request header
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Continue with the request
          return handler.next(options); // Proceed with HTTP request execution
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Optional: Global trigger pointing users back to the login page
            // if their backend session explicitly fails validation
          }
          return handler.next(e);
        },
      ),
    );
  }
}
