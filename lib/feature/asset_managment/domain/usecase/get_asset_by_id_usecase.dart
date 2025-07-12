import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';

class GetAssetByIdUseCase {
  final AssetRepository repository;

  GetAssetByIdUseCase(this.repository);

  Future<Either<Failure, AssetEntity>> call(int assetId) async {
    return await repository.getAssetById(assetId);
  }
}