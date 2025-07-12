import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/repository/loan_repository.dart';
import 'package:dartz/dartz.dart';

class ReturnAssetUseCase {
  final LoanRepository repository;

  ReturnAssetUseCase(this.repository);

  Future<Either<Failure, void>> call(int loanId) async {
    return await repository.returnLoan(loanId);
  }
}