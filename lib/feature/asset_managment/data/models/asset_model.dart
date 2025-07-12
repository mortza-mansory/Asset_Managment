// lib/feature/asset_managment/data/models/asset_model.dart

import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
// import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart'; // اگر نیاز نیست، حذف شود

class AssetModel {
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
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssetModel({
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

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      assetId: json['asset_id'] as String,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      rfidTag: json['rfid_tag'] as String,
      model: json['model'] as String?,
      serialNumber: json['serial_number'] as String?,
      technicalSpecs: json['technical_specs'] as String?,
      location: json['location'] as String?,
      locationAddress: json['location_address'] as String?, // جدید
      custodian: json['custodian'] as String?,
      value: json['value'] as int?,
      registrationDate: json['registration_date'] != null
          ? DateTime.parse(json['registration_date'])
          : null,
      warrantyEndDate: json['warranty_end_date'] != null
          ? DateTime.parse(json['warranty_end_date'])
          : null,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'asset_id': assetId,
      'category_id': categoryId,
      'name': name,
      'rfid_tag': rfidTag,
      'model': model,
      'serial_number': serialNumber,
      'technical_specs': technicalSpecs,
      'location': location,
      'location_address': locationAddress, // جدید
      'custodian': custodian,
      'value': value,
      'registration_date': registrationDate?.toIso8601String(),
      'warranty_end_date': warrantyEndDate?.toIso8601String(),
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AssetEntity toEntity() {
    return AssetEntity(
      id: id,
      companyId: companyId,
      assetId: assetId,
      categoryId: categoryId,
      name: name,
      rfidTag: rfidTag,
      model: model,
      serialNumber: serialNumber,
      technicalSpecs: technicalSpecs,
      location: location,
      locationAddress: locationAddress, // جدید
      custodian: custodian,
      value: value,
      registrationDate: registrationDate,
      warrantyEndDate: warrantyEndDate,
      description: description,
      status: AssetStatus.values.firstWhere((e) => e.name == status),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}