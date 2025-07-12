// lib/feature/asset_managment/domain/usecase/get_asset_by_rfid_usecase.dart

import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';

class GetAssetByRfidUseCase {
  final AssetRepository repository;

  GetAssetByRfidUseCase(this.repository);

  Future<Either<Failure, AssetEntity>> call(String rfidTag) async {
    return await repository.getAssetByRfid(rfidTag);
  }
}