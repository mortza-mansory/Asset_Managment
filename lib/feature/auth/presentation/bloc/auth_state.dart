part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSignUpSuccess extends AuthState {
  final String tempToken;

  AuthSignUpSuccess(this.tempToken);
}

class AuthLoginSuccess extends AuthState {
  final String tempToken;

  AuthLoginSuccess(this.tempToken);
}

class AuthOtpVerified extends AuthState {
  final String accessToken;
  final String refreshToken;

  AuthOtpVerified(this.accessToken, this.refreshToken);
}

class TokenVerified extends AuthState {
  final bool isValid;

  TokenVerified(this.isValid);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}