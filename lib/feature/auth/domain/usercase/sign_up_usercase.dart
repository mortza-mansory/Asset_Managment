import 'package:assetsrfid/feature/auth/domain/entity/temp_token_entity.dart';
import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<TempTokenEntity> call({
    required String username,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    String? governmentId,
    String? governmentName,
  }) async {
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }
    return await repository.signUp(
      username: username,
      password: password,
      phoneNumber: phoneNumber,
      governmentId: governmentId,
      governmentName: governmentName,
    );
  }
}