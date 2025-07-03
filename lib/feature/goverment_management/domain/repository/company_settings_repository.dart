import 'package:assetsrfid/feature/goverment_management/domain/entities/company_overview_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';

abstract class CompanySettingsRepository {
  Future<Either<Failure, CompanyOverviewEntity>> getCompanyOverview(int companyId);
}