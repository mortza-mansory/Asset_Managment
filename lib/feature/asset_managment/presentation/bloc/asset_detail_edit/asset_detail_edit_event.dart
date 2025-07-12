// lib/feature/asset_managment/presentation/bloc/asset_detail_edit/asset_detail_edit_event.dart

import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart'; // برای AssetStatus

abstract class AssetDetailEditEvent extends Equatable {
  const AssetDetailEditEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssetForEdit extends AssetDetailEditEvent {
  final AssetEntity asset; // دارایی که قرار است ویرایش شود

  const LoadAssetForEdit({required this.asset});

  @override
  List<Object> get props => [asset];
}

class UpdateAssetDetails extends AssetDetailEditEvent {
  final int assetId;
  final String? name;
  final String? model;
  final String? serialNumber;
  final String? location; // آدرس توصیفی
  final String? locationAddress; // جدید: مختصات جغرافیایی به صورت رشته (lon,lat)
  final String? custodian;
  final int? value;
  final String? description;
  final AssetStatus? status;
  // اگر فیلدهای دیگر مانند categoryId, registrationDate, warrantyEndDate را هم می‌خواهید ویرایش کنید، اضافه کنید

  const UpdateAssetDetails({
    required this.assetId,
    this.name,
    this.model,
    this.serialNumber,
    this.location,
    this.locationAddress, // جدید
    this.custodian,
    this.value,
    this.description,
    this.status,
  });

  @override
  List<Object?> get props => [assetId, name, model, serialNumber, location, locationAddress, custodian, value, description, status];
}