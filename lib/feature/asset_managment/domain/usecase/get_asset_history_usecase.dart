
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_history_entity.dart'; // این Entity جدید است
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';

class GetAssetHistoryUseCase {
  final AssetRepository repository;

  GetAssetHistoryUseCase(this.repository);

  Future<Either<Failure, List<AssetHistoryEntity>>> call(int assetId) async {
    return await repository.getAssetHistory(assetId);
  }
}