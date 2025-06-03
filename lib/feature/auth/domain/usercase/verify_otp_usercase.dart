import 'package:assetsrfid/feature/auth/data/models/token_response_model.dart';
import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<TokenResponseModel> call({
    required String tempToken,
    required String otp,
  }) async {
    return await repository.verifyOtp(
      tempToken: tempToken,
      otp: otp,
    );
  }
}