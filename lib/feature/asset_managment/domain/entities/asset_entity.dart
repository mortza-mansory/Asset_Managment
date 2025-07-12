// lib/feature/asset_managment/domain/entities/asset_entity.dart

import 'package:assetsrfid/feature/asset_managment/data/models/asset_model.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart';

class AssetEntity {
  final int id;
  final int companyId;
  final String assetId;
  final int categoryId;
  final String name;
  final String rfidTag;
  final String? model;
  final String? serialNumber;
  final String? technicalSpecs;
  final String? location; // آدرس توصیفی
  final String? locationAddress; // جدید: مختصات جغرافیایی به صورت رشته (lon,lat)
  final String? custodian;
  final int? value;
  final DateTime? registrationDate;
  final DateTime? warrantyEndDate;
  final String? description;
  final AssetStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssetEntity({
    required this.id,
    required this.companyId,
    required this.assetId,
    required this.categoryId,
    required this.name,
    required this.rfidTag,
    this.model,
    this.serialNumber,
    this.technicalSpecs,
    this.location,
    this.locationAddress, // جدید
    this.custodian,
    this.value,
    this.registrationDate,
    this.warrantyEndDate,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssetEntity.fromResponse(AssetModel model) {
    return AssetEntity(
      id: model.id,
      companyId: model.companyId,
      assetId: model.assetId,
      categoryId: model.categoryId,
      name: model.name,
      rfidTag: model.rfidTag,
      model: model.model,
      serialNumber: model.serialNumber,
      technicalSpecs: model.technicalSpecs,
      location: model.location,
      locationAddress: model.locationAddress, // جدید
      custodian: model.custodian,
      value: model.value,
      registrationDate: model.registrationDate,
      warrantyEndDate: model.warrantyEndDate,
      description: model.description,
      status: AssetStatus.values.firstWhere((e) => e.name == model.status),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}