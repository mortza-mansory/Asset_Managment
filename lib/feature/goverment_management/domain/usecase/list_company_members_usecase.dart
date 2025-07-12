import 'package:assetsrfid/feature/goverment_management/domain/entities/company_member_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/company_members_repository.dart';

class ListCompanyMembersUseCase {
  final CompanyMembersRepository repository;

  ListCompanyMembersUseCase(this.repository);

  Future<Either<Failure, List<CompanyMemberEntity>>> call(int companyId) async {
    return await repository.getCompanyMembers(companyId);
  }
}