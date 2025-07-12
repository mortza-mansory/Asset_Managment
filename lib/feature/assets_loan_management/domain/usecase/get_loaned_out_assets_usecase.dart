import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/repository/loan_repository.dart';
import 'package:dartz/dartz.dart';

class GetLoanedOutAssetsUseCase {
  final LoanRepository repository;

  GetLoanedOutAssetsUseCase(this.repository);

  Future<Either<Failure, List<LoanEntity>>> call(int companyId) async {
    return await repository.getLoanedOutAssets(companyId);
  }
}