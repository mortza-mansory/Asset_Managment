import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/domain/entities/invitation_entity.dart';

abstract class InvitationRepository {
  Future<Either<Failure, Map<String, dynamic>>> sendInvitation({
    required int companyId,
    required String identifier,
    required String role,
    required bool canManageGovernmentAdmins,
    required bool canManageOperators,
  });
  Future<Either<Failure, List<InvitationEntity>>> getMyInvitations();
  Future<Either<Failure, void>> respondToInvitation({required String token, required bool accept});
}