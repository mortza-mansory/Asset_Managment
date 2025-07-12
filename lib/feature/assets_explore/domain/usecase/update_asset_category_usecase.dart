// lib/feature/asset_managment/domain/usecase/update_asset_category_usecase.dart

import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateAssetCategoryUseCase {
  final AssetRepository repository;

  UpdateAssetCategoryUseCase(this.repository);

  Future<Either<Failure, AssetCategoryEntity>> call({
    required int categoryId,
    required int companyId,
    String? name,
    int? code,
    String? description,
    String? iconName,
    String? colorHex,
  }) async {
    return await repository.updateAssetCategory(
      categoryId: categoryId,
      companyId: companyId,
      name: name,
      code: code,
      description: description,
      iconName: iconName,
      colorHex: colorHex,
    );
  }
}