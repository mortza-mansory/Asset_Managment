
part of 'asset_managment_bloc.dart';

abstract class AssetManagmentEvent extends Equatable {
  const AssetManagmentEvent();

  @override
  List<Object> get props => [];
}

class LoadAssets extends AssetManagmentEvent {
  final int companyId;
  final int page;
  final int perPage;
  final String? searchQuery;
  final int? categoryId;

  const LoadAssets({
    required this.companyId,
    this.page = 1,
    this.perPage = 20,
    this.searchQuery,
    this.categoryId,
  });

  @override
  List<Object> get props => [companyId, page, perPage, searchQuery ?? '', categoryId ?? 0];
}

class CheckAssetsAndNavigateIfNeeded extends AssetManagmentEvent {
  final int companyId;

  const CheckAssetsAndNavigateIfNeeded({required this.companyId});

  @override
  List<Object> get props => [companyId];
}

