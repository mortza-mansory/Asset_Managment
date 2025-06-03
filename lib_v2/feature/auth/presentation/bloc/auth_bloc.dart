import 'package:assetsrfid/feature/auth/domain/usercase/login_usercase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/sign_up_usercase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_otp_usercase.dart';
import 'package:assetsrfid/feature/auth/domain/usercase/verify_token_usercase.dart';
import 'package:assetsrfid/feature/auth/utils/token_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final LoginUseCase loginUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final VerifyTokenUseCase verifyTokenUseCase;
  final TokenStorage tokenStorage;

  AuthBloc({
    required this.signUpUseCase,
    required this.loginUseCase,
    required this.verifyOtpUseCase,
    required this.verifyTokenUseCase,
    required this.tokenStorage,
  }) : super(AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<LoginEvent>(_onLogin);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<VerifyTokenEvent>(_onVerifyToken);
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final tempToken = await signUpUseCase(
        username: event.username,
        password: event.password,
        confirmPassword: event.confirmPassword,
        phoneNumber: event.phoneNumber,
        governmentId: event.governmentId,
        governmentName: event.governmentName,
      );
      emit(AuthSignUpSuccess(tempToken.tempToken));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final tempToken = await loginUseCase(
        username: event.username,
        password: event.password,
      );
      emit(AuthLoginSuccess(tempToken.tempToken));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final tokenResponse = await verifyOtpUseCase(
        tempToken: event.tempToken,
        otp: event.otp,
      );
      await tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );
      emit(AuthOtpVerified(tokenResponse.accessToken, tokenResponse.refreshToken));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyToken(VerifyTokenEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isValid = await verifyTokenUseCase(event.accessToken);
      emit(TokenVerified(isValid));
    } catch (e) {
      emit(TokenVerified(false));
    }
  }
}