// lib/feature/asset_managment/presentation/bloc/asset_history/asset_history_state.dart

import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_history_entity.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart'; // برای AssetEventType enum
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart'; // برای نمایش خلاصه دارایی در هدر

abstract class AssetHistoryState extends Equatable {
  const AssetHistoryState();

  @override
  List<Object?> get props => [];
}

class AssetHistoryInitial extends AssetHistoryState {}

class AssetHistoryLoading extends AssetHistoryState {
  const AssetHistoryLoading();

  @override
  List<Object> get props => [];
}

class AssetHistoryLoaded extends AssetHistoryState {
  final AssetEntity asset; // برای نمایش خلاصه دارایی در هدر
  final List<AssetHistoryEntity> allHistory; // تمامی رویدادهای تاریخچه (فیلتر نشده)
  final List<AssetHistoryEntity> filteredHistory; // رویدادهای فیلتر شده
  final AssetEventType? currentFilter; // فیلتر فعال کنونی

  const AssetHistoryLoaded({
    required this.asset,
    required this.allHistory,
    required this.filteredHistory,
    this.currentFilter,
  });

  AssetHistoryLoaded copyWith({
    AssetEntity? asset,
    List<AssetHistoryEntity>? allHistory,
    List<AssetHistoryEntity>? filteredHistory,
    AssetEventType? currentFilter,
  }) {
    return AssetHistoryLoaded(
      asset: asset ?? this.asset,
      allHistory: allHistory ?? this.allHistory,
      filteredHistory: filteredHistory ?? this.filteredHistory,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  @override
  List<Object?> get props => [asset, allHistory, filteredHistory, currentFilter];
}

class AssetHistoryError extends AssetHistoryState {
  final String message;

  const AssetHistoryError({required this.message});

  @override
  List<Object> get props => [message];
}