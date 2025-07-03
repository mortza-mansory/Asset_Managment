import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/auth/domain/entity/reset_code_entity.dart';
import 'package:assetsrfid/feature/auth/domain/entity/temp_token_entity.dart';
import 'package:assetsrfid/feature/auth/domain/entity/token_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, TempTokenEntity>> signup({required String username, required String password, required String phoneNum, String? email});
  Future<Either<Failure, TokenEntity>> verifyOtp({required int userId, required String otp, required String tempToken}); // <--- این خط تغییر کرد
  Future<Either<Failure, TempTokenEntity>> login({required String username, required String password});
  Future<Either<Failure, TokenEntity>> verifyLoginOtp({required int userId, required String otp, required String tempToken});
  Future<Either<Failure, ResetCodeEntity>> requestResetCode(String identifier);
  Future<Either<Failure, void>> verifyResetCode({required int userId, required String code, required String newPassword});
  Future<Either<Failure, bool>> verifyToken(String token);
}
