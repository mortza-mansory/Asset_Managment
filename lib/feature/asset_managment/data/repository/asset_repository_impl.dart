import 'dart:convert';
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/core/services/cache_service.dart';
import 'package:assetsrfid/feature/asset_managment/data/datasource/asset_remote_datasource.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_category_model.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_model.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_history_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/repository/asset_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';

class AssetRepositoryImpl implements AssetRepository {
  final AssetRemoteDataSource remoteDataSource;
  final CacheService cacheService;

  AssetRepositoryImpl({required this.remoteDataSource, required this.cacheService});

  @override
  Future<Either<Failure, List<AssetEntity>>> getAssets({
    required int companyId,
    int page = 1,
    int perPage = 20,
    String? searchQuery,
    int? categoryId,
  }) async {
    try {
      final cachedAssetsJson = cacheService.getAssets(companyId, searchQuery, categoryId, page, perPage);
      if (cachedAssetsJson != null) {
        final cachedAssetModels = cachedAssetsJson.map((json) => AssetModel.fromJson(json)).toList();
        final cachedAssetEntities = cachedAssetModels.map((model) => AssetEntity.fromResponse(model)).toList();
        print('Fetching assets from cache: $companyId, $searchQuery, $categoryId');
        return Right(cachedAssetEntities);
      }

      final assetModels = await remoteDataSource.getAssets(
        companyId: companyId,
        page: page,
        perPage: perPage,
        searchQuery: searchQuery,
        categoryId: categoryId,
      );
      final assetEntities = assetModels.map((model) => AssetEntity.fromResponse(model)).toList();

      final assetsJsonToCache = assetModels.map((model) => model.toJson()).toList();
      await cacheService.saveAssets(companyId, searchQuery, categoryId, page, perPage, assetsJsonToCache);

      print('Fetching assets from network and caching: $companyId, $searchQuery, $categoryId');
      return Right(assetEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AssetCategoryEntity>>> getAssetCategories({required int companyId}) async {
    try {
      final cachedCategoriesJson = cacheService.getCategories(companyId: companyId);
      if (cachedCategoriesJson != null) {
        final cachedCategoryModels = cachedCategoriesJson.map((json) => AssetCategoryModel.fromJson(json)).toList();
        final cachedCategoryEntities = cachedCategoryModels.map((model) => AssetCategoryEntity.fromResponse(model)).toList();
        print('Fetching categories from cache.');
        return Right(cachedCategoryEntities);
      }

      final categoryModels = await remoteDataSource.getAssetCategories(companyId: companyId);
      final categoryEntities = categoryModels.map((model) => AssetCategoryEntity.fromResponse(model)).toList();

      final categoriesJsonToCache = categoryModels.map((model) => model.toJson()).toList();
      await cacheService.saveCategories(categoriesJsonToCache, companyId: companyId);

      print('Fetching categories from network and caching.');
      return Right(categoryEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssetCategoryEntity>> createAssetCategory({
    required int companyId,
    required String name,
    required int code,
    String? description,
    String? iconName,
    String? colorHex,
  }) async {
    try {
      final categoryModel = await remoteDataSource.createAssetCategory(
        companyId: companyId,
        name: name,
        code: code,
        description: description,
        iconName: iconName,
        colorHex: colorHex,
      );
      await cacheService.clearCategoriesCacheForCompany(companyId);
      return Right(AssetCategoryEntity.fromResponse(categoryModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssetCategoryEntity>> updateAssetCategory({
    required int categoryId,
    required int companyId,
    String? name,
    int? code,
    String? description,
    String? iconName,
    String? colorHex,
  }) async {
    try {
      final updatedCategoryModel = await remoteDataSource.updateAssetCategory(
        categoryId: categoryId,
        companyId: companyId,
        name: name,
        code: code,
        description: description,
        iconName: iconName,
        colorHex: colorHex,
      );
      await cacheService.clearCategoriesCacheForCompany(companyId);
      return Right(AssetCategoryEntity.fromResponse(updatedCategoryModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAssetCategory({
    required int categoryId,
    required int companyId,
  }) async {
    try {
      await remoteDataSource.deleteAssetCategory(
        categoryId: categoryId,
        companyId: companyId,
      );
      await cacheService.clearCategoriesCacheForCompany(companyId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssetEntity>> updateAsset(int assetId, Map<String, dynamic> updateData) async {
    try {
      final updatedAssetModel = await remoteDataSource.updateAsset(assetId, updateData);
      return Right(AssetEntity.fromResponse(updatedAssetModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssetEntity>> getAssetByRfid(String rfidTag) async {
    try {
      final assetModel = await remoteDataSource.getAssetByRfid(rfidTag);
      return Right(AssetEntity.fromResponse(assetModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AssetHistoryEntity>>> getAssetHistory(int assetId) async {
    try {
      final historyModels = await remoteDataSource.getAssetHistory(assetId);
      final historyEntities = historyModels.map((model) => AssetHistoryEntity.fromResponse(model)).toList();
      return Right(historyEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssetEntity>> getAssetById(int assetId) async {
    try {
      final assetModel = await remoteDataSource.getAssetById(assetId);
      return Right(AssetEntity.fromResponse(assetModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> downloadExcelTemplate(String language) async {
    try {
      final filePath = await remoteDataSource.downloadExcelTemplate(language);
      return Right(filePath);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadExcelFile(PlatformFile file) async {
    try {
      final result = await remoteDataSource.uploadExcelFile(file);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}