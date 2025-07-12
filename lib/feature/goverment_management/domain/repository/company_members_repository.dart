import 'package:assetsrfid/feature/goverment_management/domain/entities/company_member_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';

abstract class CompanyMembersRepository {
  Future<Either<Failure, List<CompanyMemberEntity>>> getCompanyMembers(int companyId);
  Future<Either<Failure, void>> updateMemberRole(
      int companyId,
      int userId,
      String newRole, {
        required bool canManageGovernmentAdmins,
        required bool canManageOperators,
      });
  Future<Either<Failure, void>> removeMember(int companyId, int userId);
}