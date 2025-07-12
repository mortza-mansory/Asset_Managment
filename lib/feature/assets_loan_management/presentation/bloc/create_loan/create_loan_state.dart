import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';

abstract class CreateLoanState extends Equatable {
  const CreateLoanState();

  @override
  List<Object> get props => [];
}

class CreateLoanInitial extends CreateLoanState {}

class CreateLoanLoading extends CreateLoanState {}

class CreateLoanSuccess extends CreateLoanState {
  final LoanEntity loan;

  const CreateLoanSuccess(this.loan);

  @override
  List<Object> get props => [loan];
}

class CreateLoanError extends CreateLoanState {
  final String message;

  const CreateLoanError(this.message);

  @override
  List<Object> get props => [message];
}

class AssetDetailsLoaded extends CreateLoanState {
  final AssetEntity asset;

  const AssetDetailsLoaded(this.asset);

  @override
  List<Object> get props => [asset];
}

class ScanFieldError extends CreateLoanState {
  final String field; // 'asset' or 'recipient'
  final String message;

  const ScanFieldError(this.field, this.message);

  @override
  List<Object> get props => [field, message];
}