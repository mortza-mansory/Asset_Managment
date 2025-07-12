import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/repository/loan_repository.dart';
import 'package:dartz/dartz.dart';

class CreateLoanUseCase {
  final LoanRepository repository;

  CreateLoanUseCase(this.repository);

  Future<Either<Failure, LoanEntity>> call(LoanCreationRequestEntity request) async {
    return await repository.createLoan(request);
  }
}