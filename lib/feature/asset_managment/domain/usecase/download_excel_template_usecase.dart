import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';

class DownloadExcelTemplateUsecase {
  final AssetRepository repository;

  DownloadExcelTemplateUsecase(this.repository);

  Future<Either<Failure, String>> call(String language) {
    return repository.downloadExcelTemplate(language);
  }
}