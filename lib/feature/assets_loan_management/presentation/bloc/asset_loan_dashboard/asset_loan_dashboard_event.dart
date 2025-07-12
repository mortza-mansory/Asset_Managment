import 'package:equatable/equatable.dart';

abstract class AssetLoanDashboardEvent extends Equatable {
  const AssetLoanDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadLoans extends AssetLoanDashboardEvent {}

class ReturnLoanEvent extends AssetLoanDashboardEvent {
  final int loanId;

  const ReturnLoanEvent(this.loanId);

  @override
  List<Object?> get props => [loanId];
}