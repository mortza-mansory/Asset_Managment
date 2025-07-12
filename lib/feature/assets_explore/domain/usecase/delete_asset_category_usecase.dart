
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteAssetCategoryUseCase {
  final AssetRepository repository;

  DeleteAssetCategoryUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required int categoryId,
    required int companyId,
  }) async {
    return await repository.deleteAssetCategory(
      categoryId: categoryId,
      companyId: companyId,
    );
  }
}