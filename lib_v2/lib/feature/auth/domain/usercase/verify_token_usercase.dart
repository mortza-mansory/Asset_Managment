import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';

class VerifyTokenUseCase {
  final AuthRepository repository;

  VerifyTokenUseCase(this.repository);

  Future<bool> call(String accessToken) async {
    return await repository.verifyAccessToken(accessToken);
  }
}