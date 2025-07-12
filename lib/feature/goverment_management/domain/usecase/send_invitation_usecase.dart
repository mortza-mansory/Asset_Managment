import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/invitation_repository.dart';

class SendInvitationUseCase {
  final InvitationRepository repository;

  SendInvitationUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required int companyId,
    required String identifier,
    required String role,
    required bool canManageGovernmentAdmins,
    required bool canManageOperators,
  }) async {
    return await repository.sendInvitation(
      companyId: companyId,
      identifier: identifier,
      role: role,
      canManageGovernmentAdmins: canManageGovernmentAdmins,
      canManageOperators: canManageOperators, // Passed
    );
  }
}