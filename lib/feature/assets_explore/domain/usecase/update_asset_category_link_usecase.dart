// lib/feature/asset_managment/domain/usecase/update_asset_category_link_usecase.dart

import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateAssetCategoryLinkUseCase {
  final AssetRepository repository;

  UpdateAssetCategoryLinkUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required List<int> assetIds,
    required int newCategoryId,
  }) async {
    List<Future<Either<Failure, AssetEntity>>> updateFutures = [];

    for (int assetId in assetIds) {
      updateFutures.add(
        repository.updateAsset(
          assetId,
          {'category_id': newCategoryId}, // Send only the category_id to update
        ),
      );
    }

    // Wait for all updates to complete
    final results = await Future.wait(updateFutures);

    // Check if any update failed and return the first failure
    for (var result in results) {
      if (result.isLeft()) {
        // تغییر: استخراج Failure و بازگرداندن آن به شکل صحیح
        return Left(result.fold((failure) => failure, (_) => throw Exception('Unexpected Right value in failed future')));
      }
    }
    return const Right(unit); // All updates successful
  }
}