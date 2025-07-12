
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateAssetUseCase {
  final AssetRepository repository;

  UpdateAssetUseCase(this.repository);

  Future<Either<Failure, AssetEntity>> call(
      int assetId, Map<String, dynamic> updateData) async {
    return await repository.updateAsset(assetId, updateData);
  }
}