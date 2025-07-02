abstract class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String username;
  final String password;
  final String phoneNum;
  final String? email;
  SignUpEvent({required this.username, required this.password, required this.phoneNum, this.email});
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;
  LoginEvent({required this.username, required this.password});
}

class VerifyOtpEvent extends AuthEvent {
  final int userId;
  final String otp;
  final String tempToken;
  VerifyOtpEvent({required this.userId, required this.otp, required this.tempToken});
}

class VerifyTokenEvent extends AuthEvent {
  final String token;
  VerifyTokenEvent(this.token);
}
class RequestResetCodeEvent extends AuthEvent {
  final String identifier;
  RequestResetCodeEvent(this.identifier);
}

class VerifyResetCodeEvent extends AuthEvent {
  final int userId;
  final String code;
  final String newPassword;
  VerifyResetCodeEvent({required this.userId, required this.code, required this.newPassword});
}
class CheckUserStatus extends AuthEvent {}
class LogoutEvent extends AuthEvent {}