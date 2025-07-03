import 'package:assetsrfid/feature/goverment_management/domain/entities/company_overview_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/data/datasource/company_remote_datasource.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/company_settings_repository.dart';

class CompanySettingsRepositoryImpl implements CompanySettingsRepository {
  final CompanyRemoteDataSource remoteDataSource;

  CompanySettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CompanyOverviewEntity>> getCompanyOverview(int companyId) async {
    try {
      final companyOverviewModel = await remoteDataSource.getCompanyOverview(companyId);
      return Right(companyOverviewModel);
    } on ServerException {
      return Left(ServerFailure(message: 'خطا در دریافت اطلاعات از سرور'));
    }
  }
}