// assetsrfid/lib/feature/asset_managment/presentation/bloc/asset_explore_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_categories_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_assets_usecase.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/bloc/assets_explore/asset_explore_event.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/bloc/assets_explore/asset_explore_state.dart';

// Import entities for type hinting and data structure
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';


class AssetExploreBloc extends Bloc<AssetExploreEvent, AssetExploreState> {
  final GetAssetsUseCase getAssetsUseCase;
  final GetAssetCategoriesUseCase getAssetCategoriesUseCase;
  final SessionService sessionService;

  AssetExploreBloc({
    required this.getAssetsUseCase,
    required this.getAssetCategoriesUseCase,
    required this.sessionService,
  }) : super(AssetExploreInitial()) {
    on<FetchAssetsAndCategories>(_onFetchAssetsAndCategories);
  }

  Future<void> _onFetchAssetsAndCategories(
      FetchAssetsAndCategories event,
      Emitter<AssetExploreState> emit,
      ) async {
    final activeCompany = sessionService.getActiveCompany();
    if (activeCompany == null) {
      emit(const AssetExploreFailure(message: 'No active company selected. Please select a company.'));
      return;
    }

    // Capture previous state's data if it was loaded, to pass to loading state
    List<AssetCategoryEntity> previousCategories = [];
    List<AssetEntity> previousAssets = [];
    String? previousSearchQuery;
    int? previousSelectedCategoryId;

    // Corrected logic to capture previous state data
    if (state is AssetExploreLoaded) {
      final loadedState = state as AssetExploreLoaded;
      previousCategories = loadedState.categories;
      previousAssets = loadedState.assets;
      previousSearchQuery = loadedState.currentSearchQuery;
      previousSelectedCategoryId = loadedState.selectedCategoryId;
    } else if (state is AssetExploreLoading) { // No need for !state.isInitialLoad here in the type check
      final loadingState = state as AssetExploreLoading; // Explicitly cast here for clarity
      // If we're already loading a filter, take its previous values
      previousCategories = loadingState.previousCategories;
      previousAssets = loadingState.previousAssets;
      previousSearchQuery = loadingState.previousSearchQuery;
      previousSelectedCategoryId = loadingState.previousSelectedCategoryId;
    }


    emit(AssetExploreLoading(
      isInitialLoad: event.isInitialFetch,
      previousAssets: previousAssets, // Pass previous data
      previousCategories: previousCategories, // Pass previous data
      previousSearchQuery: previousSearchQuery,
      previousSelectedCategoryId: previousSelectedCategoryId,
    ));

    // Fetch categories
    final categoriesResult = await getAssetCategoriesUseCase(companyId: activeCompany.id);
    List<AssetCategoryEntity> fetchedCategories = [];
    categoriesResult.fold(
          (failure) {
        emit(AssetExploreFailure(message: 'Failed to load categories: ${_mapFailureToMessage(failure)}'));
        return;
      },
          (data) {
        fetchedCategories = data;
        if (!fetchedCategories.any((cat) => cat.id == 0)) {
          fetchedCategories.insert(0, const AssetCategoryEntity(id: 0, name: 'All', code: 0, iconName: 'category_outlined', colorHex: '#42A5F5'));
        }
      },
    );

    if (state is AssetExploreFailure) return; // Check again if state changed to Failure during category fetch

    // Fetch assets
    final assetsResult = await getAssetsUseCase(
      companyId: activeCompany.id,
      searchQuery: event.searchQuery,
      categoryId: event.categoryId,
      page: 1,
      perPage: 20,
    );

    assetsResult.fold(
          (failure) => emit(AssetExploreFailure(message: 'Failed to load assets: ${_mapFailureToMessage(failure)}')),
          (assets) => emit(AssetExploreLoaded(
        assets: assets,
        categories: fetchedCategories,
        selectedCategoryId: event.categoryId ?? (fetchedCategories.isNotEmpty ? fetchedCategories.first.id : null),
        currentSearchQuery: event.searchQuery,
        hasMore: assets.length >= 20,
      )),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      case UnknownFailure:
        return (failure as UnknownFailure).message;
      default:
        return 'Unexpected error occurred';
    }
  }
}