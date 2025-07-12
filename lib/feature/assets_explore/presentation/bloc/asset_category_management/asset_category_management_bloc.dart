// lib/feature/asset_managment/presentation/bloc/asset_category_management/asset_category_management_bloc.dart

import 'package:assetsrfid/feature/assets_explore/domain/usecase/create_asset_category_usecase.dart';
import 'package:assetsrfid/feature/assets_explore/domain/usecase/delete_asset_category_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_categories_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_assets_usecase.dart';
import 'package:assetsrfid/feature/assets_explore/domain/usecase/update_asset_category_link_usecase.dart';
import 'package:assetsrfid/feature/assets_explore/domain/usecase/update_asset_category_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'asset_category_management_event.dart';
import 'asset_category_management_state.dart';


class AssetCategoryManagementBloc extends Bloc<AssetCategoryManagementEvent, AssetCategoryManagementState> {
  final GetAssetCategoriesUseCase getAssetCategoriesUseCase;
  final GetAssetsUseCase getAssetsUseCase;
  final CreateAssetCategoryUseCase createAssetCategoryUseCase;
  final UpdateAssetCategoryUseCase updateAssetCategoryUseCase;
  final DeleteAssetCategoryUseCase deleteAssetCategoryUseCase;
  final UpdateAssetCategoryLinkUseCase updateAssetCategoryLinkUseCase;
  final SessionService sessionService;

  AssetCategoryManagementBloc({
    required this.getAssetCategoriesUseCase,
    required this.getAssetsUseCase,
    required this.createAssetCategoryUseCase,
    required this.updateAssetCategoryUseCase,
    required this.deleteAssetCategoryUseCase,
    required this.updateAssetCategoryLinkUseCase,
    required this.sessionService,
  }) : super(AssetCategoryManagementInitial()) {
    on<LoadCategoriesAndAssets>(_onLoadCategoriesAndAssets);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<SelectCategoryForAssetManagement>(_onSelectCategoryForAssetManagement);
    on<LoadAssetsForLinking>(_onLoadAssetsForLinking);
    on<AddAssetsToSelectedCategory>(_onAddAssetsToSelectedCategory);
    on<RemoveAssetsFromSelectedCategory>(_onRemoveAssetsFromSelectedCategory);
    on<ClearSelectedAssetsForLinking>(_onClearSelectedAssetsForLinking);
    on<SearchAssetsInCategory>(_onSearchAssetsInCategory);
  }

  int? get _currentCompanyId => sessionService.getActiveCompany()?.id;

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      default:
        return 'An unexpected error occurred.';
    }
  }

  Future<void> _onLoadCategoriesAndAssets(
      LoadCategoriesAndAssets event,
      Emitter<AssetCategoryManagementState> emit,
      ) async {
    if (_currentCompanyId == null) {
      emit(const AssetCategoryManagementFailure(message: 'No active company selected.'));
      return;
    }

    emit(const AssetCategoryManagementLoading(message: 'Loading categories and assets...'));

    final categoriesResult = await getAssetCategoriesUseCase(companyId: _currentCompanyId!);
    final assetsResult = await getAssetsUseCase(companyId: _currentCompanyId!); // Load all assets initially

    List<AssetCategoryEntity> categories = [];
    List<AssetEntity> allAssets = [];

    categoriesResult.fold(
          (failure) => emit(AssetCategoryManagementFailure(message: _mapFailureToMessage(failure))),
          (data) => categories = data,
    );

    assetsResult.fold(
          (failure) => emit(AssetCategoryManagementFailure(message: _mapFailureToMessage(failure))),
          (data) => allAssets = data,
    );

    if (state is AssetCategoryManagementFailure) return; // If any previous fetch failed

    emit(AssetCategoryManagementLoaded(
      categories: categories,
      availableAssets: allAssets, // All assets initially available
    ));
  }

  Future<void> _onCreateCategory(
      CreateCategory event,
      Emitter<AssetCategoryManagementState> emit,
      ) async {
    emit(const AssetCategoryManagementLoading(message: 'Creating category...', isOverlay: true));

    final result = await createAssetCategoryUseCase(
      companyId: event.companyId,
      name: event.name,
      code: event.code,
      description: event.description,
      iconName: event.iconName,
      colorHex: event.colorHex,
    );

    await result.fold(
          (failure) async => emit(AssetCategoryManagementFailure(message: _mapFailureToMessage(failure), showDialog: true)),
          (category) async {
        // Reload all categories after successful creation
        await _onLoadCategoriesAndAssets(LoadCategoriesAndAssets(companyId: event.companyId), emit);
        if (state is! AssetCategoryManagementFailure) {
          emit(AssetCategoryManagementSuccess(message: 'Category "${category.name}" created successfully!', category: category));
        }
      },
    );
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event,
      Emitter<AssetCategoryManagementState> emit,
      ) async {
    emit(const AssetCategoryManagementLoading(message: 'Updating category...', isOverlay: true));

    final result = await updateAssetCategoryUseCase(
      categoryId: event.categoryId,
      companyId: event.companyId,
      name: event.name,
      code: event.code,
      description: event.description,
      iconName: event.iconName,
      colorHex: event.colorHex,
    );

    await result.fold(
          (failure) async => emit(AssetCategoryManagementFailure(message: _mapFailureToMessage(failure), showDialog: true)),
          (category) async {
        await _onLoadCategoriesAndAssets(LoadCategoriesAndAssets(companyId: event.companyId), emit);
        if (state is! AssetCategoryManagementFailure) {
          emit(AssetCategoryManagementSuccess(message: 'Category "${category.name}" updated successfully!', category: category));
        }
      },
    );
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event,
      Emitter<AssetCategoryManagementState> emit,
      ) async {
    emit(const AssetCategoryManagementLoading(message: 'Deleting category...', isOverlay: true));

    final result = await deleteAssetCategoryUseCase(
      categoryId: event.categoryId,
      companyId: event.companyId,
    );

    await result.fold(
          (failure) async => emit(AssetCategoryManagementFailure(message: _mapFailureToMessage(failure), showDialog: true)),
          (_) async {
        await _onLoadCategoriesAndAssets(LoadCategoriesAndAssets(companyId: event.companyId), emit);
        if (state is! AssetCategoryManagementFailure) {
          emit(const AssetCategoryManagementSuccess(message: 'Category deleted successfully!'));
        }
      },
    );
  }

  Future<void> _onSelectCategoryForAssetManagement(
      SelectCategoryForAssetManagement event,
      Emitter<AssetCategoryManagementState> emit,
      ) async {
    if (state is! AssetCategoryManagementLoaded) {
      emit(const AssetCategoryManagementFailure(message: 'Cannot select category, data not loaded.'));
      return;
    }
    final loadedState = state as AssetCategoryManagementLoaded;

    final selectedCategory = loadedState.categories.firstWhere(
          (cat) => cat.id == event.categoryId,
      orElse: () => throw Exception('Category not found'),
    );

    // Filter assets that belong to this category
    final assetsInSelectedCategory = loadedState.availableAssets
        .where((asset) => asset.categoryId == event.categoryId)
        .toList();

    emit(loadedState.copyWith(
      selectedCategory: selectedCategory,
      assetsInCategory: assetsInSelectedCategory,
      selectedAssetsForLinking: [], // Clear any previous selections
    ));
  }

  Future<void> _onLoadAssetsForLinking(
      LoadAssetsForLinking event,
      Emitter<AssetCategoryManagementState> emit,
      ) async {
    if (state is! AssetCategoryManagementLoaded) {
      emit(const AssetCategoryManagementFailure(message: 'Cannot load assets, categories not loaded.'));
      return;
    }
    final loadedState = state as AssetCategoryManagementLoaded;

    emit(AssetCategoryManagementLoading(
      message: event.searchQuery != null ? 'Searching assets...' : 'Loading all assets...',
      isOverlay: true,
    ));

    final assetsResult = await getAssetsUseCase(
      companyId: event.companyId,
      searchQuery: event.searchQuery,
      categoryId: null,
    );

    await assetsResult.fold(
          (failure) async => emit(AssetCategoryManagementFailure(message: _mapFailureToMessage(failure))),
          (List<AssetEntity> allAssets) async {
        final List<AssetEntity> typedAllAssets = allAssets;

        final currentCategoryAssets = loadedState.selectedCategory != null
            ? (typedAllAssets.where((asset) => asset.categoryId == loadedState.selectedCategory!.id).toList() as List<AssetEntity>)
            : <AssetEntity>[];

        final selectableAssets = typedAllAssets
            .where((asset) => asset.categoryId != loadedState.selectedCategory?.id)
            .toList();

        emit(AssetLinkingSelectionState(
          categories: loadedState.categories,
          selectedCategory: loadedState.selectedCategory,
          assetsInCategory: currentCategoryAssets,
          selectableAssets: selectableAssets,
          currentSelectedAssetIds: loadedState.selectedAssetsForLinking,
          currentSearchQuery: event.searchQuery,
          availableAssetsFromBloc: typedAllAssets,
        ));
      },
    );
  }
  Future<void> _onAddAssetsToSelectedCategory(
      AddAssetsToSelectedCategory event,
      Emitter<AssetCategoryManagementState> emit,
      ) async {
    if (_currentCompanyId == null || state is! AssetCategoryManagementLoaded) {
      emit(const AssetCategoryManagementFailure(message: 'Error: No active company or data not loaded.'));
      return;
    }
    final loadedState = state as AssetCategoryManagementLoaded;

    if (loadedState.selectedCategory == null) {
      emit(const AssetCategoryManagementFailure(message: 'Please select a category first.'));
      return;
    }

    emit(const AssetCategoryManagementLoading(message: 'Adding assets to category...', isOverlay: true));

    final result = await updateAssetCategoryLinkUseCase(
      assetIds: event.assetIds,
      newCategoryId: event.categoryId,
    );

    await result.fold(
          (failure) async => emit(AssetCategoryManagementFailure(message: _mapFailureToMessage(failure), showDialog: true)),
          (_) async {
        // Reload all data to reflect changes
        await _onLoadCategoriesAndAssets(LoadCategoriesAndAssets(companyId: _currentCompanyId!), emit);
        if (state is! AssetCategoryManagementFailure) {
          // Re-select the category to update its asset list
          add(SelectCategoryForAssetManagement(categoryId: event.categoryId, companyId: _currentCompanyId!));
          emit(const AssetCategoryManagementSuccess(message: 'Assets added to category successfully!'));
        }
      },
    );
  }

  Future<void> _onRemoveAssetsFromSelectedCategory(
      RemoveAssetsFromSelectedCategory event,
      Emitter<AssetCategoryManagementState> emit,
      ) async {
    if (_currentCompanyId == null || state is! AssetCategoryManagementLoaded) {
      emit(const AssetCategoryManagementFailure(message: 'Error: No active company or data not loaded.'));
      return;
    }
    final loadedState = state as AssetCategoryManagementLoaded;

    if (loadedState.selectedCategory == null) {
      emit(const AssetCategoryManagementFailure(message: 'Please select a category first.'));
      return;
    }

    // Backend endpoint for removing from category: set category_id to a 'null' or 'uncategorized' category ID.
    // Assuming there's a default "Uncategorized" category with ID 1 (or any specific ID) in your system
    // Or, backend logic handles setting category_id to NULL.
    // For now, let's assume setting category_id to 0 for unlinking, or you can use a specific "Uncategorized" category ID.
    // If backend only allows non-null category_id, you must have an "Uncategorized" category.
    // For this example, let's assume `0` will signify "no category" or "uncategorized" or your backend has logic for it.
    // Or you can create a specific "Uncategorized" category in your backend.
    final int uncategorizedId = 0; // Adjust based on your backend's "uncategorized" category ID or null handling

    emit(const AssetCategoryManagementLoading(message: 'Removing assets from category...', isOverlay: true));

    final result = await updateAssetCategoryLinkUseCase(
      assetIds: event.assetIds,
      newCategoryId: uncategorizedId, // Assign to an uncategorized state/category
    );

    await result.fold(
          (failure) async => emit(AssetCategoryManagementFailure(message: _mapFailureToMessage(failure), showDialog: true)),
          (_) async {
        await _onLoadCategoriesAndAssets(LoadCategoriesAndAssets(companyId: _currentCompanyId!), emit);
        if (state is! AssetCategoryManagementFailure) {
          add(SelectCategoryForAssetManagement(categoryId: event.categoryId, companyId: _currentCompanyId!));
          emit(const AssetCategoryManagementSuccess(message: 'Assets removed from category successfully!'));
        }
      },
    );
  }

  void _onClearSelectedAssetsForLinking(
      ClearSelectedAssetsForLinking event,
      Emitter<AssetCategoryManagementState> emit,
      ) {
    if (state is AssetLinkingSelectionState) {
      final selectionState = state as AssetLinkingSelectionState;
      emit(selectionState.copyWithSelection(currentSelectedAssetIds: []));
    } else if (state is AssetCategoryManagementLoaded) {
      final loadedState = state as AssetCategoryManagementLoaded;
      emit(loadedState.copyWith(selectedAssetsForLinking: []));
    }
  }

  Future<void> _onSearchAssetsInCategory(
      SearchAssetsInCategory event,
      Emitter<AssetCategoryManagementState> emit,
      ) async {
    if (_currentCompanyId == null || state is! AssetCategoryManagementLoaded) {
      emit(const AssetCategoryManagementFailure(message: 'Error: No active company or data not loaded.'));
      return;
    }
    final loadedState = state as AssetCategoryManagementLoaded;

    emit(const AssetCategoryManagementLoading(message: 'Searching assets in category...', isOverlay: true));

    // Fetch assets specifically for the selected category with search query
    final assetsResult = await getAssetsUseCase(
      companyId: event.companyId,
      categoryId: event.categoryId,
      searchQuery: event.searchQuery,
    );

    await assetsResult.fold(
          (failure) async => emit(AssetCategoryManagementFailure(message: _mapFailureToMessage(failure))),
          (List<AssetEntity> assets) async {
        emit(loadedState.copyWith(assetsInCategory: assets));
      },
    );
  }
}