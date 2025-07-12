import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/data/datasource/company_remote_datasource.dart';
import 'package:assetsrfid/feature/goverment_management/domain/entities/company_member_entity.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/company_members_repository.dart';

class CompanyMembersRepositoryImpl implements CompanyMembersRepository {
  final CompanyRemoteDataSource remoteDataSource;

  CompanyMembersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CompanyMemberEntity>>> getCompanyMembers(int companyId) async {
    try {
      final members = await remoteDataSource.getCompanyMembers(companyId);
      return Right(members);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unknown error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMemberRole(
      int companyId,
      int userId,
      String newRole, {
        required bool canManageGovernmentAdmins,
        required bool canManageOperators,
      }) async {
    try {
      await remoteDataSource.updateMemberRole(
        companyId,
        userId,
        newRole,
        canManageGovernmentAdmins: canManageGovernmentAdmins,
        canManageOperators: canManageOperators,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unknown error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(int companyId, int userId) async {
    try {
      await remoteDataSource.removeMember(companyId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unknown error: ${e.toString()}'));
    }
  }
}