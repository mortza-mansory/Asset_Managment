
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';

class CreateAssetCategoryUseCase {
  final AssetRepository repository;

  CreateAssetCategoryUseCase(this.repository);

  Future<Either<Failure, AssetCategoryEntity>> call({
    required int companyId,
    required String name,
    required int code,
    String? description,
    String? iconName,
    String? colorHex,
  }) async {
    return await repository.createAssetCategory(
      companyId: companyId,
      name: name,
      code: code,
      description: description,
      iconName: iconName,
      colorHex: colorHex,
    );
  }
}