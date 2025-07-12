import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';

abstract class CreateLoanEvent extends Equatable {
  const CreateLoanEvent();

  @override
  List<Object> get props => [];
}

class CreateLoanSubmitted extends CreateLoanEvent {
  final String rfidTag; // Changed from assetId (int) to rfidTag (String)
  final int recipientId;
  final String? externalRecipient;
  final String? phoneNumber;
  final DateTime endDate;
  final String? details;

  const CreateLoanSubmitted({
    required this.rfidTag, // Changed from assetId
    required this.recipientId,
    this.externalRecipient,
    this.phoneNumber,
    required this.endDate,
    this.details,
  });

  @override
  List<Object> get props => [rfidTag, recipientId, endDate, details ?? '', externalRecipient ?? '', phoneNumber ?? ''];
}

class GetAssetDetailsById extends CreateLoanEvent {
  final String assetRfid;

  const GetAssetDetailsById(this.assetRfid);

  @override
  List<Object> get props => [assetRfid];
}

class GetUserProfileById extends CreateLoanEvent {
  final int userId;

  const GetUserProfileById(this.userId);

  @override
  List<Object> get props => [userId];
}