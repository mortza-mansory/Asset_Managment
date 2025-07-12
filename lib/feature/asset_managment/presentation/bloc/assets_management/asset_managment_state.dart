
part of 'asset_managment_bloc.dart';

abstract class AssetManagmentState extends Equatable {
  const AssetManagmentState();

  @override
  List<Object> get props => [];
}

class AssetManagmentInitial extends AssetManagmentState {}

class AssetManagmentLoading extends AssetManagmentState {}

class AssetsLoaded extends AssetManagmentState {
  final List<AssetEntity> assets;
  final bool isEmpty; // Added flag

  const AssetsLoaded({required this.assets, this.isEmpty = false});

  @override
  List<Object> get props => [assets, isEmpty];
}

class AssetManagmentError extends AssetManagmentState {
  final String message;

  const AssetManagmentError({required this.message});

  @override
  List<Object> get props => [message];
}

// ... other states if any ...