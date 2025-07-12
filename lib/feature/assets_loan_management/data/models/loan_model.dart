// lib/feature/assets_loan_management/data/models/loan_model.dart

import 'dart:convert';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_model.dart';
import 'package:assetsrfid/feature/profile/data/model/user_profile_model.dart';
import 'package:assetsrfid/feature/profile/domain/entity/user_profile_entity.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart'; // Import for AssetStatus enum

class LoanModel extends LoanEntity {
  const LoanModel({
    required super.id,
    required super.assetRfidTag,
    required super.companyId,
    super.recipientId,
    super.externalRecipient,
    super.phoneNumber,
    required super.loanDate,
    required super.endDate,
    super.returnDate,
    required super.status,
    super.details,
    super.qrCodeUrl,
    super.asset,
    super.recipientUser,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    // Safely get 'is_active' and map it to a string status for the LoanEntity
    final bool isActive = json['is_active'] as bool? ?? false;
    final String loanStatus = isActive ? 'on_loan' : 'returned'; // Assuming 'on_loan' if active, 'returned' otherwise

    // Construct a minimal AssetEntity from the flat JSON fields
    final AssetEntity? assetEntity = (json['asset_name'] as String?) != null && (json['asset_name'] as String).isNotEmpty
        ? AssetEntity(
      id: json['id'] as int, // Reusing loan ID, or fetch actual asset ID if available from backend
      companyId: json['company_id'] as int,
      assetId: json['asset_rfid_tag'] as String, // Using rfid_tag as assetId for now
      categoryId: 0, // Default category ID, as it's not in the loan response
      name: json['asset_name'] as String,
      rfidTag: json['asset_rfid_tag'] as String,
      status: isActive ? AssetStatus.on_loan : AssetStatus.inactive, // Map to AssetStatus enum
      createdAt: DateTime.parse(json['created_at']), // Use loan creation date for asset if no specific asset creation date is available
      updatedAt: DateTime.parse(json['created_at']), // Use loan creation date for asset
    )
        : null;

    // Construct a minimal UserProfileEntity from the flat JSON fields
    final UserProfileEntity? recipientUserEntity = (json['recipient_name'] as String?) != null && (json['recipient_name'] as String).isNotEmpty
        ? UserProfileEntity(
      id: json['recipient_id'] as int? ?? 0, // Use recipient_id if available, default to 0
      username: json['recipient_name'] as String,
      isActive: true, // Assuming active for simplicity
    )
        : null;

    return LoanModel(
      id: json['id'] as int,
      assetRfidTag: json['asset_rfid_tag'] as String,
      companyId: json['company_id'] as int,
      recipientId: json['recipient_id'] as int?,
      externalRecipient: json['external_recipient'] as String?,
      phoneNumber: json['phone_number'] as String?, // This field might be null from backend
      loanDate: DateTime.parse(json['start_date'] as String), // Correctly map from 'start_date'
      endDate: DateTime.parse(json['end_date'] as String),
      returnDate: json['actual_return_date'] != null ? DateTime.parse(json['actual_return_date'] as String) : null, // Correctly map from 'actual_return_date'
      status: loanStatus, // Use the mapped string status
      details: json['details'] as String?,
      qrCodeUrl: json['qr_code_url'] as String?, // This field might be null from backend
      asset: assetEntity, // Assign the constructed AssetEntity
      recipientUser: recipientUserEntity, // Assign the constructed UserProfileEntity
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_rfid_tag': assetRfidTag,
      'company_id': companyId,
      'recipient_id': recipientId,
      'external_recipient': externalRecipient,
      'phone_number': phoneNumber,
      'loan_date': loanDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'status': status,
      'details': details,
      'qr_code_url': qrCodeUrl,
      'asset': (asset as AssetModel?)?.toJson(),
      'recipient_user': (recipientUser as UserProfileModel?)?.toJson(),
    };
  }
}

class LoanCreationRequestModel extends LoanCreationRequestEntity {
  const LoanCreationRequestModel({
    required super.assetRfidTag,
    required super.companyId,
    super.recipientId,
    super.externalRecipient,
    super.phoneNumber,
    required super.endDate,
    super.details,
  });

  factory LoanCreationRequestModel.fromEntity(LoanCreationRequestEntity entity) {
    return LoanCreationRequestModel(
      assetRfidTag: entity.assetRfidTag,
      companyId: entity.companyId,
      recipientId: entity.recipientId,
      externalRecipient: entity.externalRecipient,
      phoneNumber: entity.phoneNumber,
      endDate: entity.endDate,
      details: entity.details,
    );
  }

  factory LoanCreationRequestModel.fromJson(Map<String, dynamic> json) {
    return LoanCreationRequestModel(
      assetRfidTag: json['asset_rfid_tag'] as String,
      companyId: json['company_id'] as int,
      recipientId: json['recipient_id'] as int?,
      externalRecipient: json['external_recipient'] as String?,
      phoneNumber: json['phone_number'] as String?,
      endDate: DateTime.parse(json['end_date'] as String),
      details: json['details'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'asset_rfid_tag': assetRfidTag, // <--- این خط باید به 'asset_rfid_tag' بازگردانده شود
      'company_id': companyId,
      'recipient_id': recipientId,
      'external_recipient': externalRecipient,
      'recipient_phone_number': phoneNumber,
      'end_date': endDate.toIso8601String(),
      'details': details,
    };
  }
}