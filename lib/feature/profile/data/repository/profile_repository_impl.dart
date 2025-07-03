import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/profile/data/datasource/profile_remote_datasource.dart';
import 'package:assetsrfid/feature/profile/domain/entity/user_profile_entity.dart';
import 'package:assetsrfid/feature/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    try {
      final userProfile = await remoteDataSource.getUserProfile();
      return Right(userProfile);
    } on ServerException {
      return Left(ServerFailure(message: 'خطا در دریافت اطلاعات از سرور'));
    }
  }
}