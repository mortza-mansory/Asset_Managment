import 'package:assetsrfid/feature/auth/domain/entity/temp_token_entity.dart';
import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';

class SignupUseCase {
  final AuthRepository repository;
  SignupUseCase(this.repository);

  Future<Either<Failure, TempTokenEntity>> call({
    required String username,
    required String password,
    required String phoneNum,
    String? email,
  }) {
    return repository.signup(username: username, password: password, phoneNum: phoneNum, email: email);
  }
}