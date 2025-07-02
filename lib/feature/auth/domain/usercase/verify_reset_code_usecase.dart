import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';

class VerifyResetCodeUseCase {
  final AuthRepository repository;
  VerifyResetCodeUseCase(this.repository);

  Future<Either<Failure, void>> call({required int userId, required String code, required String newPassword}) {
    return repository.verifyResetCode(userId: userId, code: code, newPassword: newPassword);
  }
}