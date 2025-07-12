
import 'package:equatable/equatable.dart';

abstract class AssetDetailEvent extends Equatable {
  const AssetDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssetDetailByRfid extends AssetDetailEvent {
  final String rfidTag;

  const LoadAssetDetailByRfid({required this.rfidTag});

  @override
  List<Object> get props => [rfidTag];
}

class LoadAssetHistoryInDetail extends AssetDetailEvent { // نام تغییر یافت تا با AssetHistoryBloc.LoadAssetHistoryEvent تداخل نداشته باشد
  final int assetId;

  const LoadAssetHistoryInDetail({required this.assetId});

  @override
  List<Object> get props => [assetId];
}