import 'package:assetsrfid/feature/auth/domain/entity/token_entity.dart';
import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';

class VerifyLoginOtpUseCase {
  final AuthRepository repository;
  VerifyLoginOtpUseCase(this.repository);

  Future<Either<Failure, TokenEntity>> call({required int userId, required String otp, required String tempToken}) {
    return repository.verifyLoginOtp(userId: userId, otp: otp, tempToken: tempToken);
  }
}