/// Ø­Ø§Ù„Ø§Øª Ø§Ù„Ù…ØµØ§Ø¯Ù‚Ø©
/// Authentication states
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
