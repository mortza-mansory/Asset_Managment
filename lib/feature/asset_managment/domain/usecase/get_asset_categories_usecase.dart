
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart'; // مهم: این import باید صحیح باشد
import 'package:dartz/dartz.dart';

class GetAssetCategoriesUseCase {
  final AssetRepository repository;

  GetAssetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<AssetCategoryEntity>>> call({required int companyId}) async {
    return await repository.getAssetCategories(companyId: companyId);
  }
}