import 'package:assetsrfid/feature/auth/domain/entity/reset_code_entity.dart';
import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';

class RequestResetCodeUseCase {
  final AuthRepository repository;
  RequestResetCodeUseCase(this.repository);

  Future<Either<Failure, ResetCodeEntity>> call(String identifier) {
    return repository.requestResetCode(identifier);
  }
}