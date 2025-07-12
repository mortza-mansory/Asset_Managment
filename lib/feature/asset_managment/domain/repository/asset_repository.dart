// lib/feature/asset_managment/domain/repository/asset_repository.dart

import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_history_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart'; // Keep if used for @required or similar, otherwise can be removed.
import 'package:file_picker/file_picker.dart'; // Import PlatformFile

abstract class AssetRepository {
  Future<Either<Failure, List<AssetEntity>>> getAssets({
    required int companyId,
    int page = 1,
    int perPage = 20,
    String? searchQuery,
    int? categoryId,
  });

  Future<Either<Failure, List<AssetCategoryEntity>>> getAssetCategories({required int companyId});

  // CRUD methods for categories
  Future<Either<Failure, AssetCategoryEntity>> createAssetCategory({
    required int companyId,
    required String name,
    required int code,
    String? description,
    String? iconName,
    String? colorHex,
  });

  Future<Either<Failure, AssetCategoryEntity>> updateAssetCategory({
    required int categoryId,
    required int companyId,
    String? name,
    int? code,
    String? description,
    String? iconName,
    String? colorHex,
  });

  Future<Either<Failure, Unit>> deleteAssetCategory({
    required int categoryId,
    required int companyId,
  });

  Future<Either<Failure, AssetEntity>> updateAsset(int assetId, Map<String, dynamic> updateData);

  Future<Either<Failure, AssetEntity>> getAssetByRfid(String rfidTag);
  Future<Either<Failure, List<AssetHistoryEntity>>> getAssetHistory(int assetId);

  Future<Either<Failure, AssetEntity>> getAssetById(int assetId);

  // New methods for bulk upload/download
  Future<Either<Failure, String>> downloadExcelTemplate(String language);
  Future<Either<Failure, Map<String, dynamic>>> uploadExcelFile(PlatformFile file);
}