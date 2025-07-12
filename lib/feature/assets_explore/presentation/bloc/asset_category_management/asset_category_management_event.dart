// lib/feature/asset_managment/presentation/bloc/asset_category_management/asset_category_management_event.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // For IconData, Color

abstract class AssetCategoryManagementEvent extends Equatable {
  const AssetCategoryManagementEvent();

  @override
  List<Object?> get props => [];
}

// 1. Event for initial loading of categories and assets
class LoadCategoriesAndAssets extends AssetCategoryManagementEvent {
  final int companyId;
  const LoadCategoriesAndAssets({required this.companyId});

  @override
  List<Object> get props => [companyId];
}

// 2. Event for creating a new category
class CreateCategory extends AssetCategoryManagementEvent {
  final int companyId;
  final String name;
  final int code;
  final String? description;
  final String? iconName;
  final String? colorHex;

  const CreateCategory({
    required this.companyId,
    required this.name,
    required this.code,
    this.description,
    this.iconName,
    this.colorHex,
  });

  @override
  List<Object?> get props => [companyId, name, code, description, iconName, colorHex];
}

// 3. Event for updating an existing category
class UpdateCategory extends AssetCategoryManagementEvent {
  final int categoryId;
  final int companyId;
  final String? name;
  final int? code;
  final String? description;
  final String? iconName;
  final String? colorHex;

  const UpdateCategory({
    required this.categoryId,
    required this.companyId,
    this.name,
    this.code,
    this.description,
    this.iconName,
    this.colorHex,
  });

  @override
  List<Object?> get props => [categoryId, companyId, name, code, description, iconName, colorHex];
}

// 4. Event for deleting a category
class DeleteCategory extends AssetCategoryManagementEvent {
  final int categoryId;
  final int companyId;

  const DeleteCategory({
    required this.categoryId,
    required this.companyId,
  });

  @override
  List<Object> get props => [categoryId, companyId];
}

// 5. Event to select a category for managing its assets
class SelectCategoryForAssetManagement extends AssetCategoryManagementEvent {
  final int categoryId;
  final int companyId;

  const SelectCategoryForAssetManagement({
    required this.categoryId,
    required this.companyId,
  });

  @override
  List<Object> get props => [categoryId, companyId];
}

// 6. Event to initiate selection of assets to add/remove
class LoadAssetsForLinking extends AssetCategoryManagementEvent {
  final int companyId;
  final String? searchQuery; // For searching available assets

  const LoadAssetsForLinking({required this.companyId, this.searchQuery});

  @override
  List<Object?> get props => [companyId, searchQuery];
}

// 7. Event to add selected assets to the currently chosen category
class AddAssetsToSelectedCategory extends AssetCategoryManagementEvent {
  final int categoryId; // The category to add assets to
  final List<int> assetIds; // The IDs of assets to add

  const AddAssetsToSelectedCategory({
    required this.categoryId,
    required this.assetIds,
  });

  @override
  List<Object> get props => [categoryId, assetIds];
}

// 8. Event to remove selected assets from the currently chosen category
class RemoveAssetsFromSelectedCategory extends AssetCategoryManagementEvent {
  final int categoryId; // The category to remove assets from
  final List<int> assetIds; // The IDs of assets to remove

  const RemoveAssetsFromSelectedCategory({
    required this.categoryId,
    required this.assetIds,
  });

  @override
  List<Object> get props => [categoryId, assetIds];
}

// 9. Event to clear the selection of assets in asset selection mode
class ClearSelectedAssetsForLinking extends AssetCategoryManagementEvent {
  const ClearSelectedAssetsForLinking();
}

// 10. Event for searching assets within the currently selected category
class SearchAssetsInCategory extends AssetCategoryManagementEvent {
  final int categoryId;
  final int companyId;
  final String searchQuery;

  const SearchAssetsInCategory({required this.categoryId, required this.companyId, required this.searchQuery});

  @override
  List<Object> get props => [categoryId, companyId, searchQuery];
}