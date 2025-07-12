import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/company_members_repository.dart';

class UpdateMemberRoleUseCase {
  final CompanyMembersRepository repository;

  UpdateMemberRoleUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int companyId,
    required int userId,
    required String newRole,
    required bool canManageGovernmentAdmins,
    required bool canManageOperators,
  }) async {
    return await repository.updateMemberRole(
      companyId,
      userId,
      newRole,
      canManageGovernmentAdmins: canManageGovernmentAdmins, // Passed
      canManageOperators: canManageOperators,               // Passed
    );
  }
}