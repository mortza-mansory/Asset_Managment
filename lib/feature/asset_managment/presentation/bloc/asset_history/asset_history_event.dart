
import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart'; // برای AssetEventType

abstract class AssetHistoryEvent extends Equatable {
  const AssetHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssetHistoryEvent extends AssetHistoryEvent {
  final int assetId; // ID دارایی که تاریخچه آن را می‌خواهیم

  const LoadAssetHistoryEvent({required this.assetId});

  @override
  List<Object> get props => [assetId];
}

class FilterAssetHistory extends AssetHistoryEvent {
  final AssetEventType? filterType; // فیلتر بر اساس نوع رویداد (null برای همه)

  const FilterAssetHistory({this.filterType});

  @override
  List<Object?> get props => [filterType];
}