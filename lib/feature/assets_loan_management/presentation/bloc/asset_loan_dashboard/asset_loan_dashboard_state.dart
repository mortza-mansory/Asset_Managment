import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';

abstract class AssetLoanDashboardState extends Equatable {
  const AssetLoanDashboardState();

  @override
  List<Object?> get props => [];
}

class AssetLoanDashboardInitial extends AssetLoanDashboardState {}

class AssetLoanDashboardLoading extends AssetLoanDashboardState {}

class AssetLoanDashboardLoaded extends AssetLoanDashboardState {
  final List<LoanEntity> myLoans;
  final List<LoanEntity> loanedOutAssets;

  const AssetLoanDashboardLoaded({
    required this.myLoans,
    required this.loanedOutAssets,
  });

  @override
  List<Object?> get props => [myLoans, loanedOutAssets];
}

class AssetLoanDashboardError extends AssetLoanDashboardState {
  final String message;

  const AssetLoanDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Added missing LoanReturnSuccess state
class LoanReturnSuccess extends AssetLoanDashboardState {
  final int loanId; // Assuming loanId is an int based on usage

  const LoanReturnSuccess(this.loanId);

  @override
  List<Object?> get props => [loanId];
}