import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';
import 'package:dartz/dartz.dart';

abstract class LoanRepository {
  Future<Either<Failure, List<LoanEntity>>> getMyLoans(int userId, int companyId);
  Future<Either<Failure, List<LoanEntity>>> getLoanedOutAssets(int companyId);
  Future<Either<Failure, LoanEntity>> createLoan(LoanCreationRequestEntity request);
  // Corrected: loanId should be int
  Future<Either<Failure, void>> returnLoan(int loanId);
  Future<Either<Failure, LoanEntity>> getLoanById(String loanId);
}