// assetsrfid/lib/feature/asset_managment/domain/usecase/get_assets_usecase.dart

import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';

class GetAssetsUseCase {
  final AssetRepository repository;

  GetAssetsUseCase(this.repository);

  Future<Either<Failure, List<AssetEntity>>> call({
    required int companyId,
    int page = 1,
    int perPage = 20,
    String? searchQuery,
    int? categoryId,
  }) async {
    return await repository.getAssets(
      companyId: companyId,
      page: page,
      perPage: perPage,
      searchQuery: searchQuery,
      categoryId: categoryId,
    );
  }
}