import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/data/datasource/company_remote_datasource.dart';
import 'package:assetsrfid/feature/goverment_management/domain/entities/invitation_entity.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/invitation_repository.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  final CompanyRemoteDataSource remoteDataSource;

  InvitationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendInvitation({
    required int companyId,
    required String identifier,
    required String role,
    required bool canManageGovernmentAdmins,
    required bool canManageOperators,
  }) async {
    try {
      final response = await remoteDataSource.sendInvitation(
        companyId,
        identifier,
        role,
        canManageGovernmentAdmins: canManageGovernmentAdmins,
        canManageOperators: canManageOperators,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unknown error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InvitationEntity>>> getMyInvitations() async {
    try {
      final invitations = await remoteDataSource.getMyInvitations();
      return Right(invitations);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unknown error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> respondToInvitation({required String token, required bool accept}) async {
    try {
      await remoteDataSource.respondToInvitation(token, accept);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unknown error: ${e.toString()}'));
    }
  }
}