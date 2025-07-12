import 'package:bloc/bloc.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_history_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';

import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_categories_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_by_rfid_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_history_usecase.dart';

import 'asset_detail_event.dart';
import 'asset_detail_state.dart';


class AssetDetailBloc extends Bloc<AssetDetailEvent, AssetDetailState> {
  final GetAssetByRfidUseCase getAssetByRfidUseCase;
  final GetAssetHistoryUseCase getAssetHistoryUseCase;
  final GetAssetCategoriesUseCase getAssetCategoriesUseCase;
  final SessionService sessionService;

  AssetDetailBloc({
    required this.getAssetByRfidUseCase,
    required this.getAssetHistoryUseCase,
    required this.getAssetCategoriesUseCase,
    required this.sessionService,
  }) : super(AssetDetailInitial()) {
    on<LoadAssetDetailByRfid>(_onLoadAssetDetailByRfid);
    on<LoadAssetHistoryInDetail>(_onLoadAssetHistoryInDetail); // نام رویداد تغییر یافته
  }

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

  Future<void> _onLoadAssetDetailByRfid(
      LoadAssetDetailByRfid event,
      Emitter<AssetDetailState> emit,
      ) async {
    emit(const AssetDetailLoading(message: 'Loading asset details...'));

    final assetResult = await getAssetByRfidUseCase(event.rfidTag);

    await assetResult.fold(
          (failure) async => emit(AssetDetailError(message: _mapFailureToMessage(failure))),
          (asset) async {
        AssetCategoryEntity? category;
        if (asset.categoryId != null) {
          final categoryResult = await getAssetCategoriesUseCase(companyId: asset.companyId);
          categoryResult.fold(
                (failure) {
              print('Warning: Failed to load category for asset: ${_mapFailureToMessage(failure)}');
            },
                (categories) {
              category = categories.firstWhere(
                    (cat) => cat.id == asset.categoryId,
                orElse: () => AssetCategoryEntity(id: asset.categoryId, name: 'Unknown Category', code: 0), // Fallback
              );
            },
          );
        }

        final historyResult = await getAssetHistoryUseCase(asset.id!);
        List<AssetHistoryEntity> history = [];
        historyResult.fold(
              (failure) {
            print('Warning: Failed to load asset history: ${_mapFailureToMessage(failure)}');
          },
              (data) => history = data,
        );

        emit(AssetDetailLoaded(asset: asset, category: category, history: history));
      },
    );
  }

  Future<void> _onLoadAssetHistoryInDetail( // نام رویداد تغییر یافته
      LoadAssetHistoryInDetail event,
      Emitter<AssetDetailState> emit,
      ) async {
    if (state is! AssetDetailLoaded) {

      emit(const AssetDetailError(message: 'Asset details not loaded to fetch history.'));
      return;
    }

    final loadedState = state as AssetDetailLoaded;
    emit(const AssetDetailLoading(message: 'Loading asset history...'));

    final historyResult = await getAssetHistoryUseCase(event.assetId);

    await historyResult.fold(
          (failure) async => emit(AssetDetailError(message: _mapFailureToMessage(failure))),
          (history) async {
        emit(loadedState.copyWith(history: history));
      },
    );
  }
}