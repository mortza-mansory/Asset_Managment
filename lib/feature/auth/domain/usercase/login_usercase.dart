import 'package:assetsrfid/feature/auth/domain/entity/temp_token_entity.dart';
import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<TempTokenEntity> call({
    required String username,
    required String password,
  }) async {
    return await repository.login(
      username: username,
      password: password,
    );
  }
}