class ServerException implements Exception {
  final String message;
  final int? statusCode; // Added statusCode
  ServerException({required this.message, this.statusCode});
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});
}