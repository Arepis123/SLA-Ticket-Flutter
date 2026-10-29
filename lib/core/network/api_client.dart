import 'dart:async';

import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Thin wrapper around Dio for the Laravel API: attaches the bearer token,
/// turns failures into [ApiException]s and reports rejected tokens on
/// [unauthorized] so the app can sign out.
class ApiClient {
  ApiClient({required String baseUrl, Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/'
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers['Accept'] = 'application/json';

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final _unauthorized = StreamController<void>.broadcast();
  String? _token;

  set token(String? value) => _token = value;

  /// Fires when the server rejects the current token (expired or revoked).
  Stream<void> get unauthorized => _unauthorized.stream;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _send(() => _dio.get<Object?>(path, queryParameters: query));

  Future<Map<String, dynamic>> post(String path, {Object? data}) =>
      _send(() => _dio.post<Object?>(path, data: data));

  Future<Map<String, dynamic>> delete(String path) =>
      _send(() => _dio.delete<Object?>(path));

  Future<Map<String, dynamic>> _send(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      final body = (await request()).data;
      return body is Map<String, dynamic> ? body : const {};
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    final response = error.response;
    if (response == null) {
      return const ApiException(
        "Can't reach the server. Check your connection and try again.",
      );
    }

    final status = response.statusCode;
    final data = response.data;
    final body = data is Map<String, dynamic>
        ? data
        : const <String, dynamic>{};

    if (status == 401 && _token != null) {
      _unauthorized.add(null);
    }

    final errors = body['errors'];

    return ApiException(
      body['message'] as String? ?? 'Something went wrong (HTTP $status).',
      statusCode: status,
      fieldErrors: errors is Map<String, dynamic>
          ? errors.map(
              (field, messages) =>
                  MapEntry(field, (messages as List).cast<String>()),
            )
          : const {},
    );
  }

  Future<void> dispose() => _unauthorized.close();
}
