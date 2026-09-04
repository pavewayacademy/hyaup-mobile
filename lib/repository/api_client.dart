import 'package:dio/dio.dart';
import '../core/constants/api_endpoints.dart';
import 'auth.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final AuthRepository _authRepository = AuthRepository();

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.defaultBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String? token = await _authRepository.getIdToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Log or handle unauthorized responses globally
          return handler.next(e);
        },
      ),
    );
  }

  void setBaseUrl(String url) {
    dio.options.baseUrl = url;
  }
}
