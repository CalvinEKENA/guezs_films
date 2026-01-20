import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';

/// Configured Dio HTTP client for TMDB API
/// Includes interceptors for auth, logging, and error handling
class ApiClient {
  static Dio? _dio;

  /// Get singleton Dio instance
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  /// Create and configure Dio instance
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(seconds: ApiConstants.timeoutSeconds),
        receiveTimeout: Duration(seconds: ApiConstants.timeoutSeconds),
        sendTimeout: Duration(seconds: ApiConstants.timeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
      _RetryInterceptor(dio),
    ]);

    return dio;
  }

  /// Reset client (useful for logout)
  static void reset() {
    _dio?.close();
    _dio = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Interceptor - Adds API key to all requests
// ─────────────────────────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add API key as query parameter
    options.queryParameters['api_key'] = ApiConstants.apiKey;

    // Add default language
    options.queryParameters['language'] ??= ApiConstants.defaultLanguage;

    handler.next(options);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logging Interceptor - Logs requests and responses in debug mode
// ─────────────────────────────────────────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('🌐 REQUEST: ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('❌ ERROR: ${err.type} - ${err.message}');
    handler.next(err);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Interceptor - Transforms errors to user-friendly messages
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = ApiError.fromDioError(err);

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiError,
        message: apiError.message,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Retry Interceptor - Retries failed requests with exponential backoff
// ─────────────────────────────────────────────────────────────────────────────

class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int _maxRetries = 3;
  final Duration _retryDelay = const Duration(seconds: 1);

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on network errors or server errors
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < _maxRetries) {
        // Exponential backoff
        final delay = _retryDelay * (retryCount + 1);
        await Future.delayed(delay);

        // Update retry count
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue with error
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// API Error Model
// ─────────────────────────────────────────────────────────────────────────────

class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final ErrorType type;

  const ApiError({
    required this.message,
    this.statusCode,
    this.data,
    required this.type,
  });

  factory ApiError.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          message: 'Connection timed out. Please check your internet.',
          type: ErrorType.timeout,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return const ApiError(
          message: 'Request was cancelled.',
          type: ErrorType.cancelled,
        );

      case DioExceptionType.connectionError:
        return const ApiError(
          message: 'No internet connection. Please check your network.',
          type: ErrorType.network,
        );

      default:
        return const ApiError(
          message: 'An unexpected error occurred.',
          type: ErrorType.unknown,
        );
    }
  }

  static ApiError _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'Server error. Please try again.';

    // Try to extract message from TMDB error response
    if (data is Map && data.containsKey('status_message')) {
      message = data['status_message'] as String;
    }

    switch (statusCode) {
      case 400:
        return ApiError(
          message: message,
          statusCode: statusCode,
          data: data,
          type: ErrorType.badRequest,
        );
      case 401:
        return ApiError(
          message: 'Invalid API key. Please check your configuration.',
          statusCode: statusCode,
          data: data,
          type: ErrorType.unauthorized,
        );
      case 404:
        return ApiError(
          message: 'Content not found.',
          statusCode: statusCode,
          data: data,
          type: ErrorType.notFound,
        );
      case 429:
        return ApiError(
          message: 'Too many requests. Please wait a moment.',
          statusCode: statusCode,
          data: data,
          type: ErrorType.rateLimited,
        );
      case 500:
      case 502:
      case 503:
        return ApiError(
          message: 'Server is temporarily unavailable.',
          statusCode: statusCode,
          data: data,
          type: ErrorType.server,
        );
      default:
        return ApiError(
          message: message,
          statusCode: statusCode,
          data: data,
          type: ErrorType.unknown,
        );
    }
  }

  @override
  String toString() =>
      'ApiError: $message (type: $type, statusCode: $statusCode)';
}

enum ErrorType {
  network,
  timeout,
  unauthorized,
  notFound,
  badRequest,
  rateLimited,
  server,
  cancelled,
  unknown,
}
