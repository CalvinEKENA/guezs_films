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
