// lib/feature/assets_loan_management/domain/entities/loan_entity.dart
import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/profile/domain/entity/user_profile_entity.dart';

class LoanEntity extends Equatable {
  final int id;
  final String assetRfidTag; // <-- تغییر یافته
  final int companyId;
  final int? recipientId;
  final String? externalRecipient;
  final String? phoneNumber;
  final DateTime loanDate;
  final DateTime endDate;
  final DateTime? returnDate;
  final String status;
  final String? details;
  final String? qrCodeUrl;
  final AssetEntity? asset;
  final UserProfileEntity? recipientUser;

  const LoanEntity({
    required this.id,
    required this.assetRfidTag, // <-- تغییر یافته
    required this.companyId,
    this.recipientId,
    this.externalRecipient,
    this.phoneNumber,
    required this.loanDate,
    required this.endDate,
    this.returnDate,
    required this.status,
    this.details,
    this.qrCodeUrl,
    this.asset,
    this.recipientUser,
  });

  bool get isOverdue {
    if (returnDate != null) {
      return returnDate!.isAfter(endDate);
    }
    return endDate.isBefore(DateTime.now());
  }

  String get assetName => asset?.name ?? 'Unknown Asset';
  String get recipientName => recipientUser?.username ?? externalRecipient ?? 'Unknown Recipient';

  @override
  List<Object?> get props => [
    id,
    assetRfidTag, // <-- تغییر یافته
    companyId,
    recipientId,
    externalRecipient,
    phoneNumber,
    loanDate,
    endDate,
    returnDate,
    status,
    details,
    qrCodeUrl,
    asset,
    recipientUser,
    isOverdue,
    assetName,
    recipientName,
  ];
}

class LoanCreationRequestEntity extends Equatable {
  final String assetRfidTag; // <-- تغییر یافته
  final int companyId;
  final int? recipientId;
  final String? externalRecipient;
  final String? phoneNumber;
  final DateTime endDate;
  final String? details;

  const LoanCreationRequestEntity({
    required this.assetRfidTag, // <-- تغییر یافته
    required this.companyId,
    this.recipientId,
    this.externalRecipient,
    this.phoneNumber,
    required this.endDate,
    this.details,
  });

  @override
  List<Object?> get props => [
    assetRfidTag, // <-- تغییر یافته
    companyId,
    recipientId,
    externalRecipient,
    phoneNumber,
    endDate,
    details,
  ];
}