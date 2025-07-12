import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/company_members_repository.dart';

class RemoveMemberUseCase {
  final CompanyMembersRepository repository;

  RemoveMemberUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int companyId,
    required int userId,
  }) async {
    return await repository.removeMember(companyId, userId);
  }
}