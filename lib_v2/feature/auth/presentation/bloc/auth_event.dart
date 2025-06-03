part of 'auth_bloc.dart';

abstract class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String username;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final String? governmentId;
  final String? governmentName;

  SignUpEvent({
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
    this.governmentId,
    this.governmentName,
  });
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent({
    required this.username,
    required this.password,
  });
}

class VerifyOtpEvent extends AuthEvent {
  final String tempToken;
  final String otp;

  VerifyOtpEvent({
    required this.tempToken,
    required this.otp,
  });
}

class VerifyTokenEvent extends AuthEvent {
  final String accessToken;

  VerifyTokenEvent(this.accessToken);
}