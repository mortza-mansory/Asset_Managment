
import 'package:assetsrfid/feature/auth/domain/entity/reset_code_entity.dart';
import 'package:assetsrfid/feature/auth/domain/entity/temp_token_entity.dart';
import 'package:assetsrfid/feature/auth/domain/entity/token_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final TempTokenEntity tempTokenEntity;
  AuthOtpSent({required this.tempTokenEntity});
}

class AuthSignUpVerified extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final TokenEntity token;
  AuthLoginSuccess({required this.token});
}

class TokenVerified extends AuthState {
  final bool isValid;
  TokenVerified({required this.isValid});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}

class ResetCodeSent extends AuthState {
  final ResetCodeEntity resetCodeEntity;
  ResetCodeSent({required this.resetCodeEntity});
}

class PasswordResetSuccess extends AuthState {}

class AuthOnboardingRequired extends AuthState {}
class AuthAuthenticated extends AuthState {}
class AuthLoggedOut extends AuthState {}