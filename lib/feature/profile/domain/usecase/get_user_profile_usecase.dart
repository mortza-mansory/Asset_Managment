import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/profile/domain/entity/user_profile_entity.dart';
import 'package:assetsrfid/feature/profile/domain/repository/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call() async {
    return await repository.getUserProfile();
  }
}