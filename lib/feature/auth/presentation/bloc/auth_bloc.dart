import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/auth/domain/entity/token_entity.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/login_usercase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/request_reset_code_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/signup_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_login_otp_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_reset_code_usecase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_token_usecase.dart';
import 'package:assetsrfid/feature/auth/utils/token_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUseCase signupUseCase;
  final LoginUseCase loginUseCase;
  final VerifyLoginOtpUseCase verifyLoginOtpUseCase;
  final VerifyTokenUseCase verifyTokenUseCase;
  final RequestResetCodeUseCase requestResetCodeUseCase;
  final VerifyResetCodeUseCase verifyResetCodeUseCase;
  final TokenStorage tokenStorage;

  AuthBloc({
    required this.signupUseCase,
    required this.loginUseCase,
    required this.verifyLoginOtpUseCase,
    required this.verifyTokenUseCase,
    required this.requestResetCodeUseCase,
    required this.verifyResetCodeUseCase,
    required this.tokenStorage,
  }) : super(AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<LoginEvent>(_onLogin);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<VerifyTokenEvent>(_onVerifyToken);
    on<RequestResetCodeEvent>(_onRequestResetCode);
    on<VerifyResetCodeEvent>(_onVerifyResetCode);
    on<CheckUserStatus>(_onCheckUserStatus);
    on<LogoutEvent>(_onLogout);
  }

  void _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signupUseCase(
        username: event.username,
        password: event.password,
        phoneNum: event.phoneNum,
        email: event.email);
    result.fold(
          (failure) => emit(AuthFailure(message: failure.message)),
          (tempTokenEntity) =>
          emit(AuthOtpSent(tempTokenEntity: tempTokenEntity)),
    );
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
    await loginUseCase(username: event.username, password: event.password);
    result.fold(
          (failure) => emit(AuthFailure(message: failure.message)),
          (tempTokenEntity) =>
          emit(AuthOtpSent(tempTokenEntity: tempTokenEntity)),
    );
  }

  void _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await verifyLoginOtpUseCase(
        userId: event.userId, otp: event.otp, tempToken: event.tempToken);
    await result.fold(
          (failure) async => emit(AuthFailure(message: failure.message)),
          (tokenEntity) async {
        await tokenStorage.saveAccessToken(tokenEntity.accessToken);
        if (!emit.isDone) {
          emit(AuthLoginSuccess(token: tokenEntity));
        }
      },
    );
  }

  void _onVerifyToken(VerifyTokenEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await verifyTokenUseCase(token: event.token);
    result.fold(
          (failure) => emit(TokenVerified(isValid: false)),
          (isValid) => emit(TokenVerified(isValid: isValid)),
    );
  }

  void _onRequestResetCode(
      RequestResetCodeEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await requestResetCodeUseCase(event.identifier);
    result.fold(
          (failure) => emit(AuthFailure(message: failure.message)),
          (resetCodeEntity) => emit(ResetCodeSent(resetCodeEntity: resetCodeEntity)),
    );
  }

  void _onVerifyResetCode(
      VerifyResetCodeEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await verifyResetCodeUseCase(
        userId: event.userId, code: event.code, newPassword: event.newPassword);
    result.fold(
          (failure) => emit(AuthFailure(message: failure.message)),
          (_) => emit(PasswordResetSuccess()),
    );
  }

  void _onCheckUserStatus(CheckUserStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // شبیه‌سازی برای تست UI
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthOnboardingRequired());
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await tokenStorage.clearTokens();
    emit(AuthLoggedOut());
  }
}