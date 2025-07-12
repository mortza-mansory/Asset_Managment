// assetsrfid/lib/feature/asset_managment/presentation/bloc/asset_explore_event.dart

import 'package:equatable/equatable.dart';

abstract class AssetExploreEvent extends Equatable {
  const AssetExploreEvent();

  @override
  List<Object> get props => [];
}

class FetchAssetsAndCategories extends AssetExploreEvent {
  final int companyId;
  final String? searchQuery;
  final int? categoryId;
  final bool isInitialFetch; // To differentiate initial load from subsequent filters/searches

  const FetchAssetsAndCategories({
    required this.companyId,
    this.searchQuery,
    this.categoryId,
    this.isInitialFetch = false,
  });

  @override
  List<Object> get props => [companyId, searchQuery ?? '', categoryId ?? 0, isInitialFetch];
}

// رویدادهای دیگری مانند LoadMoreAssets برای صفحه‌بندی می‌توانند در آینده اضافه شوند.