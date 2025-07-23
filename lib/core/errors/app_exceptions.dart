/// Ø§Ø³ØªØ«Ù†Ø§Ø¡Ø§Øª Ø§Ù„ØªØ·Ø¨ÙŠÙ‚
/// App exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String? message]) 
      : super(message ?? 'Ø®Ø·Ø£ ÙÙŠ Ø§Ù„Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø´Ø¨ÙƒØ©');
}

class ServerException extends AppException {
  const ServerException([String? message]) 
      : super(message ?? 'Ø®Ø·Ø£ ÙÙŠ Ø§Ù„Ø®Ø§Ø¯Ù…');
}

class AuthException extends AppException {
  const AuthException([String? message]) 
      : super(message ?? 'Ø®Ø·Ø£ ÙÙŠ Ø§Ù„Ù…ØµØ§Ø¯Ù‚Ø©');
}

class ValidationException extends AppException {
  const ValidationException([String? message]) 
      : super(message ?? 'Ø®Ø·Ø£ ÙÙŠ Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª');
}
