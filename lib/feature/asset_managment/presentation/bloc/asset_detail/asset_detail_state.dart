// lib/feature/asset_managment/presentation/bloc/asset_detail/asset_detail_state.dart

import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_history_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';


abstract class AssetDetailState extends Equatable {
  const AssetDetailState();

  @override
  List<Object?> get props => [];
}

class AssetDetailInitial extends AssetDetailState {}

class AssetDetailLoading extends AssetDetailState {
  final String? message;

  const AssetDetailLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class AssetDetailLoaded extends AssetDetailState {
  final AssetEntity asset;
  final AssetCategoryEntity? category;
  final List<AssetHistoryEntity> history;

  const AssetDetailLoaded({
    required this.asset,
    this.category,
    this.history = const [],
  });

  AssetDetailLoaded copyWith({
    AssetEntity? asset,
    AssetCategoryEntity? category,
    List<AssetHistoryEntity>? history,
  }) {
    return AssetDetailLoaded(
      asset: asset ?? this.asset,
      category: category ?? this.category,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [asset, category, history];
}

class AssetDetailError extends AssetDetailState {
  final String message;

  const AssetDetailError({required this.message});

  @override
  List<Object> get props => [message];
}