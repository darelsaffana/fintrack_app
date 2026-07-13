import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Change this to match where your Laravel backend is running.
/// - Android emulator -> http://10.0.2.2:8000/api
/// - iOS simulator / desktop / web -> http://127.0.0.1:8000/api
/// - Physical device -> http://<your-computer-ip>:8000/api
const String kApiBaseUrl = 'http://127.0.0.1:8000/api';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;
}

/// Turns a DioException into a readable message (Laravel validation errors,
/// auth errors, or a network fallback message).
String extractErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['errors'] is Map) {
      final errors =
          (data['errors'] as Map).values.expand((v) => v is List ? v : [v]);
      if (errors.isNotEmpty) return errors.first.toString();
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Tidak dapat terhubung ke server. Periksa koneksi kamu.';
  }
  return error.toString();
}
