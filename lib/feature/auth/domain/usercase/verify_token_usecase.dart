import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';

class VerifyTokenUseCase {
  final AuthRepository repository;
  VerifyTokenUseCase(this.repository);

  Future<Either<Failure, bool>> call({required String token}) async {
    return await repository.verifyToken(token);
  }
}