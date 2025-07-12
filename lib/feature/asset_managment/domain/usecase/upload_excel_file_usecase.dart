import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';

class UploadExcelFileUsecase {
  final AssetRepository repository;

  UploadExcelFileUsecase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(PlatformFile file) {
    return repository.uploadExcelFile(file);
  }
}