
import 'package:assetsrfid/feature/auth/data/models/token_response_model.dart';
import 'package:assetsrfid/feature/auth/domain/entity/temp_token_entity.dart';

abstract class AuthRepository {
  Future<TempTokenEntity> signUp({
    required String username,
    required String password,
    required String phoneNumber,
    String? governmentId,
    String? governmentName,
  });

  Future<TempTokenEntity> login({
    required String username,
    required String password,
  });

  Future<TokenResponseModel> verifyOtp({
    required String tempToken,
    required String otp,
  });
  Future<bool> verifyAccessToken(String accessToken);
}