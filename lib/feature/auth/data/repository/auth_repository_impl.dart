import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/feature/auth/data/datasource/auth_remote_datasource.dart';

import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/auth/data/models/auth_req_models.dart';
import 'package:assetsrfid/feature/auth/domain/entity/reset_code_entity.dart';
import 'package:assetsrfid/feature/auth/domain/entity/temp_token_entity.dart';
import 'package:assetsrfid/feature/auth/domain/entity/token_entity.dart';
import 'package:assetsrfid/feature/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TempTokenEntity>> signup({required String username, required String password, required String phoneNum, String? email}) async {
    try {
      final requestModel = SignUpRequestModel(username: username, password: password, phoneNum: phoneNum, email: email);
      final responseModel = await remoteDataSource.signup(requestModel);
      return Right(TempTokenEntity(userId: responseModel.id, tempToken: responseModel.tempToken));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TempTokenEntity>> login({required String username, required String password}) async {
    try {
      final responseModel = await remoteDataSource.login(username, password);
      return Right(TempTokenEntity(userId: responseModel.userId, tempToken: responseModel.tempToken));
    } on ServerException catch(e){
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TokenEntity>> verifyOtp({required int userId, required String otp, required String tempToken}) async {
    try {
      final requestModel = VerifyOtpRequestModel(userId: userId, otp: otp, tempToken: tempToken);
      final responseModel = await remoteDataSource.verifyLoginOtp(requestModel);
      return Right(TokenEntity(accessToken: responseModel.accessToken));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
  @override
  Future<Either<Failure, ResetCodeEntity>> requestResetCode(String identifier) async {
    try {
      final responseModel = await remoteDataSource.requestResetCode(identifier);
      return Right(ResetCodeEntity(userId: responseModel.userId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> verifyResetCode({required int userId, required String code, required String newPassword}) async {
    try {
      await remoteDataSource.verifyResetCode(userId: userId, code: code, newPassword: newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
  @override
  Future<Either<Failure, TokenEntity>> verifyLoginOtp({required int userId, required String otp, required String tempToken}) async {
    try {
      final requestModel = VerifyOtpRequestModel(userId: userId, otp: otp, tempToken: tempToken);
      final responseModel = await remoteDataSource.verifyLoginOtp(requestModel);
      return Right(TokenEntity(accessToken: responseModel.accessToken));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
  @override
  Future<Either<Failure, bool>> verifyToken(String token) async {
    try {
      final isValid = await remoteDataSource.verifyToken(token);
      return Right(isValid);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}