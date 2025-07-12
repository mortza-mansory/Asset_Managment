// lib/feature/asset_managment/presentation/bloc/asset_detail_edit/asset_detail_edit_state.dart

import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';

abstract class AssetDetailEditState extends Equatable {
  const AssetDetailEditState();

  @override
  List<Object?> get props => [];
}

class AssetDetailEditInitial extends AssetDetailEditState {}

class AssetDetailEditLoading extends AssetDetailEditState {
  final String? message;

  const AssetDetailEditLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class AssetDetailEditLoaded extends AssetDetailEditState {
  final AssetEntity asset; // دارایی اصلی که در حال ویرایش است

  const AssetDetailEditLoaded({required this.asset});

  AssetDetailEditLoaded copyWith({
    AssetEntity? asset,
  }) {
    return AssetDetailEditLoaded(
      asset: asset ?? this.asset,
    );
  }

  @override
  List<Object> get props => [asset];
}

class AssetDetailEditSuccess extends AssetDetailEditState {
  final String message;
  final AssetEntity updatedAsset; // دارایی به‌روز شده

  const AssetDetailEditSuccess({required this.message, required this.updatedAsset});

  @override
  List<Object> get props => [message, updatedAsset];
}

class AssetDetailEditError extends AssetDetailEditState {
  final String message;

  const AssetDetailEditError({required this.message});

  @override
  List<Object> get props => [message];
}