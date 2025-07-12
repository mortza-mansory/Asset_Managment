// assetsrfid/lib/feature/asset_managment/presentation/bloc/asset_explore_state.dart

import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';

abstract class AssetExploreState extends Equatable {
  const AssetExploreState();

  @override
  List<Object> get props => [];
}

class AssetExploreInitial extends AssetExploreState {}

// Definition for AssetExploreLoading (only one, correct instance)
class AssetExploreLoading extends AssetExploreState {
  final bool isInitialLoad;
  final List<AssetEntity> previousAssets; // Holds previous assets if loading is not initial
  final List<AssetCategoryEntity> previousCategories; // Holds previous categories if loading is not initial
  final String? previousSearchQuery;
  final int? previousSelectedCategoryId;

  const AssetExploreLoading({
    this.isInitialLoad = true,
    this.previousAssets = const [],
    this.previousCategories = const [],
    this.previousSearchQuery,
    this.previousSelectedCategoryId,
  });

  @override
  List<Object> get props => [
    isInitialLoad,
    previousAssets,
    previousCategories,
    previousSearchQuery ?? '',
    previousSelectedCategoryId ?? 0,
  ];
}

// Definition for AssetExploreLoaded (Corrected)
class AssetExploreLoaded extends AssetExploreState {
  final List<AssetEntity> assets;
  final List<AssetCategoryEntity> categories;
  final int? selectedCategoryId;
  final String? currentSearchQuery;
  final bool hasMore;

  const AssetExploreLoaded({
    required this.assets,
    required this.categories,
    this.selectedCategoryId,
    this.currentSearchQuery,
    this.hasMore = false,
  });

  @override
  List<Object> get props => [assets, categories, selectedCategoryId ?? 0, currentSearchQuery ?? '', hasMore];
}

class AssetExploreFailure extends AssetExploreState {
  final String message;

  const AssetExploreFailure({required this.message});

  @override
  List<Object> get props => [message];
}