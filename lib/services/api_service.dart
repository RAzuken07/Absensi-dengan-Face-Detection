import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  String? _token;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    // di lib/services/api_service.dart -- interceptors logging & error details
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_token == null) await loadToken();
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          // Log request details
          try {
            print('--- API Request ---> ${options.method} ${options.uri}');
            print('Headers: ${options.headers}');
            print('QueryParameters: ${options.queryParameters}');
            // options.data bisa FormData atau Map
            if (options.data is FormData) {
              print(
                'Request data: FormData (fields=${(options.data as FormData).fields.length}, files=${(options.data as FormData).files.length})',
              );
            } else {
              print('Request data: ${options.data}');
            }
          } catch (e) {
            print('Error logging request: $e');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          try {
            print(
              '--- API Response <--- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
            );
            print('Response data: ${response.data}');
          } catch (e) {
            print('Error logging response: $e');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('--- API Error <--- ${error.runtimeType} : ${error.message}');
          // If DioError / DioException show more details
          try {
            final req = error.requestOptions;
            print('Failed request: ${req.method} ${req.uri}');
            print('Request data on error: ${req.data}');
          } catch (e) {
            // ignore
          }
          final resp = error.response;
          print('Response status: ${resp?.statusCode}');
          print('Response body: ${resp?.data}');
          // Extract error message safely
          String serverMessage;
          final body = resp?.data;
          if (body == null) {
            serverMessage = 'No response body';
          } else if (body is Map && body.containsKey('error')) {
            serverMessage = body['error'].toString();
          } else if (body is Map && body.containsKey('message')) {
            serverMessage = body['message'].toString();
          } else {
            serverMessage = body.toString();
          }
          print('Server message: $serverMessage');
                  return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    print('Token saved: ${token.substring(0, 20)}...');
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
    if (_token != null) {
      print('Token loaded from storage: ${_token!.substring(0, 20)}...');
    } else {
      print('No token found in storage');
    }
  }

  Future<String?> getToken() async {
    if (_token == null) {
      await loadToken();
    }
    return _token;
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userDataKey);
    await prefs.setBool(AppConstants.isLoggedInKey, false);
  }

  Future<void> _handleUnauthorized() async {
    await clearToken();
    // The app should navigate to login screen
    // This will be handled by the auth provider
  }

  // Convenience methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }
}
