import 'package:assetsrfid/feature/goverment_management/domain/entities/company_overview_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/company_settings_repository.dart';

class GetCompanyOverviewUseCase {
  final CompanySettingsRepository repository;

  GetCompanyOverviewUseCase(this.repository);

  Future<Either<Failure, CompanyOverviewEntity>> call(int companyId) async {
    return await repository.getCompanyOverview(companyId);
  }
}