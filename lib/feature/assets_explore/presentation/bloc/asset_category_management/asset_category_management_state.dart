// lib/feature/asset_managment/presentation/bloc/asset_category_management/asset_category_management_state.dart

import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';

abstract class AssetCategoryManagementState extends Equatable {
  const AssetCategoryManagementState();

  @override
  List<Object?> get props => [];
}

class AssetCategoryManagementInitial extends AssetCategoryManagementState {}

class AssetCategoryManagementLoading extends AssetCategoryManagementState {
  final String? message;
  final bool isOverlay; // true if loading should be an overlay on existing data

  const AssetCategoryManagementLoading({this.message, this.isOverlay = false});

  @override
  List<Object?> get props => [message, isOverlay];
}

class AssetCategoryManagementLoaded extends AssetCategoryManagementState {
  final List<AssetCategoryEntity> categories;
  final AssetCategoryEntity? selectedCategory; // The category currently being managed
  final List<AssetEntity> assetsInCategory; // Assets belonging to the selected category
  final List<AssetEntity> availableAssets; // All assets available for linking/unlinking (excluding those in current category unless filtered)
  final List<int> selectedAssetsForLinking; // IDs of assets selected in the asset linking mode
  final String? assetSearchQuery; // Search query for available assets

  const AssetCategoryManagementLoaded({
    this.categories = const [],
    this.selectedCategory,
    this.assetsInCategory = const [],
    this.availableAssets = const [],
    this.selectedAssetsForLinking = const [],
    this.assetSearchQuery,
  });

  AssetCategoryManagementLoaded copyWith({
    List<AssetCategoryEntity>? categories,
    AssetCategoryEntity? selectedCategory,
    List<AssetEntity>? assetsInCategory,
    List<AssetEntity>? availableAssets,
    List<int>? selectedAssetsForLinking,
    String? assetSearchQuery,
  }) {
    return AssetCategoryManagementLoaded(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      assetsInCategory: assetsInCategory ?? this.assetsInCategory,
      availableAssets: availableAssets ?? this.availableAssets,
      selectedAssetsForLinking: selectedAssetsForLinking ?? this.selectedAssetsForLinking,
      assetSearchQuery: assetSearchQuery ?? this.assetSearchQuery,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    selectedCategory,
    assetsInCategory,
    availableAssets,
    selectedAssetsForLinking,
    assetSearchQuery,
  ];
}

class AssetCategoryManagementSuccess extends AssetCategoryManagementState {
  final String message;
  final AssetCategoryEntity? category; // Optional: return the affected category

  const AssetCategoryManagementSuccess({required this.message, this.category});

  @override
  List<Object?> get props => [message, category];
}

class AssetCategoryManagementFailure extends AssetCategoryManagementState {
  final String message;
  final bool showDialog; // Optional: to indicate if an error dialog should be shown

  const AssetCategoryManagementFailure({required this.message, this.showDialog = false});

  @override
  List<Object> get props => [message, showDialog];
}

// State specifically for asset selection sub-flow
class AssetLinkingSelectionState extends AssetCategoryManagementLoaded {
  final List<AssetEntity> selectableAssets;
  final List<int> currentSelectedAssetIds;
  final String? currentSearchQuery;

  const AssetLinkingSelectionState({
    required super.categories,
    super.selectedCategory,
    required super.assetsInCategory, // Must be List<AssetEntity>
    required this.selectableAssets,
    required this.currentSelectedAssetIds,
    this.currentSearchQuery,
    required List<AssetEntity> availableAssetsFromBloc,
  }) : super(
    availableAssets: availableAssetsFromBloc,
    selectedAssetsForLinking: const [],
    assetSearchQuery: null,
  );

  AssetLinkingSelectionState copyWithSelection({
    List<int>? currentSelectedAssetIds,
    String? currentSearchQuery,
  }) {
    return AssetLinkingSelectionState(
      categories: categories,
      selectedCategory: selectedCategory,
      assetsInCategory: assetsInCategory,
      selectableAssets: selectableAssets,
      currentSelectedAssetIds: currentSelectedAssetIds ?? this.currentSelectedAssetIds,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      availableAssetsFromBloc: availableAssets, // استفاده از availableAssets که از super می‌آید
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    selectableAssets,
    currentSelectedAssetIds,
    currentSearchQuery,
  ];
}