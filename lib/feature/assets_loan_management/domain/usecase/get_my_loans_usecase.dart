import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/repository/loan_repository.dart';

class GetMyLoansUseCase {
  final LoanRepository repository;

  GetMyLoansUseCase(this.repository);

  Future<Either<Failure, List<LoanEntity>>> call(int userId, int companyId) async {
    return await repository.getMyLoans(userId, companyId);
  }
}