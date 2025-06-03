
import 'package:assetsrfid/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:assetsrfid/feature/auth/data/models/token_response_model.dart';
import 'package:assetsrfid/feature/auth/domain/entity/temp_token_entity.dart';
import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<TempTokenEntity> signUp({
    required String username,
    required String password,
    required String phoneNumber,
    String? governmentId,
    String? governmentName,
  }) async {
    try {
      final response = await remoteDataSource.signUp(
        username: username,
        password: password,
        phoneNumber: phoneNumber,
        governmentId: governmentId,
        governmentName: governmentName,
      );
      return response;
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  @override
  Future<TempTokenEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        username: username,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<TokenResponseModel> verifyOtp({
    required String tempToken,
    required String otp,
  }) async {
    try {
      final response = await remoteDataSource.verifyOtp(
        tempToken: tempToken,
        otp: otp,
      );
      return response;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }
  @override
  Future<bool> verifyAccessToken(String accessToken) async {
    try {
      return await remoteDataSource.verifyAccessToken(accessToken);
    } catch (e) {
      return false;
    }
  }
}