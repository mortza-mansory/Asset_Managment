import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/assets_loan_management/data/datasource/loan_remote_datasource.dart';
import 'package:assetsrfid/feature/assets_loan_management/data/models/loan_model.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/repository/loan_repository.dart';
import 'package:dartz/dartz.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LoanRemoteDataSource remoteDataSource;

  LoanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LoanEntity>>> getMyLoans(int userId, int companyId) async {
    try {
      final result = await remoteDataSource.getMyLoans(userId, companyId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LoanEntity>>> getLoanedOutAssets(int companyId) async {
    try {
      final result = await remoteDataSource.getLoanedOutAssets(companyId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoanEntity>> createLoan(LoanCreationRequestEntity request) async {
    try {
      // Fix: Use the newly defined fromEntity factory constructor
      final requestModel = LoanCreationRequestModel.fromEntity(request);
      final result = await remoteDataSource.createLoan(requestModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  // Corrected: loanId should be int as per the previous update and common practice for IDs
  Future<Either<Failure, void>> returnLoan(int loanId) async {
    try {
      await remoteDataSource.returnLoan(loanId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  // loanId is String for getLoanById, which likely refers to rfid_tag or a loan string ID
  Future<Either<Failure, LoanEntity>> getLoanById(String loanId) async {
    try {
      final result = await remoteDataSource.getLoanById(loanId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}