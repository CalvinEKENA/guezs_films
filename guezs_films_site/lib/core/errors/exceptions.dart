/// Core exceptions for error handling
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server exception occurred']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache exception occurred']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network exception occurred']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication exception occurred']);
}

/// Thrown when the user voluntarily cancels an operation (e.g. Google Sign-In back button).
/// This should be caught silently — no error message should be displayed.
class CancelledException implements Exception {}
