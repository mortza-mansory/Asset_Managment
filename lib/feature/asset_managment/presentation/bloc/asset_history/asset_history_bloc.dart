// lib/feature/asset_managment/presentation/bloc/asset_history/asset_history_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_history_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_history_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_by_id_usecase.dart'; // برای دریافت جزئیات Asset
import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart'; // برای AssetEventType enum

import 'asset_history_event.dart';
import 'asset_history_state.dart';


class AssetHistoryBloc extends Bloc<AssetHistoryEvent, AssetHistoryState> {
  final GetAssetHistoryUseCase getAssetHistoryUseCase;
  final GetAssetByIdUseCase getAssetByIdUseCase;

  AssetHistoryBloc({
    required this.getAssetHistoryUseCase,
    required this.getAssetByIdUseCase,
  }) : super(AssetHistoryInitial()) {
    on<LoadAssetHistoryEvent>(_onLoadAssetHistoryEvent);
    on<FilterAssetHistory>(_onFilterAssetHistory);
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

  Future<void> _onLoadAssetHistoryEvent(
      LoadAssetHistoryEvent event,
      Emitter<AssetHistoryState> emit,
      ) async {
    emit(const AssetHistoryLoading());

    // 1. دریافت اطلاعات خود دارایی (با استفاده از assetId)
    final assetDetailResult = await getAssetByIdUseCase(event.assetId);

    AssetEntity? asset;
    await assetDetailResult.fold(
          (failure) {
        emit(AssetHistoryError(message: _mapFailureToMessage(failure)));
        return;
      },
          (data) {
        asset = data;
      },
    );

    if (asset == null) return;

    // 2. دریافت تاریخچه وضعیت دارایی
    final historyResult = await getAssetHistoryUseCase(asset!.id!);

    List<AssetHistoryEntity> allHistory = [];

    await historyResult.fold(
          (failure) {
        emit(AssetHistoryError(message: _mapFailureToMessage(failure)));
        return;
      },
          (data) => allHistory = data,
    );

    emit(AssetHistoryLoaded(
      asset: asset!,
      allHistory: allHistory,
      filteredHistory: allHistory,
    ));
  }

  Future<void> _onFilterAssetHistory(
      FilterAssetHistory event,
      Emitter<AssetHistoryState> emit,
      ) async {
    if (state is! AssetHistoryLoaded) {
      return;
    }

    final loadedState = state as AssetHistoryLoaded;
    List<AssetHistoryEntity> newFilteredHistory;

    if (event.filterType == null) {
      newFilteredHistory = List.from(loadedState.allHistory);
    } else {
      newFilteredHistory = loadedState.allHistory
          .where((historyEvent) => historyEvent.eventType == event.filterType!.name)
          .toList();
    }

    emit(loadedState.copyWith(
      filteredHistory: newFilteredHistory,
      currentFilter: event.filterType,
    ));
  }
}