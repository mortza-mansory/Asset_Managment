import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/usecase/get_loaned_out_assets_usecase.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/usecase/get_my_loans_usecase.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/usecase/return_asset_usecase.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/asset_loan_dashboard/asset_loan_dashboard_event.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/asset_loan_dashboard/asset_loan_dashboard_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';

class AssetLoanDashboardBloc extends Bloc<AssetLoanDashboardEvent, AssetLoanDashboardState> {
  final GetMyLoansUseCase getMyLoansUseCase;
  final GetLoanedOutAssetsUseCase getLoanedOutAssetsUseCase;
  final ReturnAssetUseCase returnAssetUseCase;
  final SessionService sessionService;

  AssetLoanDashboardBloc({
    required this.getMyLoansUseCase,
    required this.getLoanedOutAssetsUseCase,
    required this.returnAssetUseCase,
    required this.sessionService,
  }) : super(AssetLoanDashboardInitial()) {
    on<LoadLoans>(_onLoadLoans);
    on<ReturnLoanEvent>(_onReturnLoan);
  }

  Future<void> _onLoadLoans(LoadLoans event, Emitter<AssetLoanDashboardState> emit) async {
    emit(AssetLoanDashboardLoading());

    final companyId = sessionService.getActiveCompany()?.id;
    if (companyId == null) {
      emit(const AssetLoanDashboardError('Company ID is not available.'));
      return;
    }

    final currentUserId = sessionService.getUserId();
    if (currentUserId == null) {
      emit(const AssetLoanDashboardError('User ID is not available. Please log in again.'));
      return;
    }

    final myLoansFuture = getMyLoansUseCase(currentUserId, companyId);
    final loanedOutAssetsFuture = getLoanedOutAssetsUseCase(companyId);

    final failureOrLoans = await Future.wait([myLoansFuture, loanedOutAssetsFuture]);

    final myLoansResult = failureOrLoans[0];
    final loanedOutAssetsResult = failureOrLoans[1];

    final myLoansFailure = myLoansResult.fold((failure) => failure, (_) => null);
    final loanedOutFailure = loanedOutAssetsResult.fold((failure) => failure, (_) => null);

    if (myLoansFailure != null || loanedOutFailure != null) {
      emit(AssetLoanDashboardError(_mapFailureToMessage(myLoansFailure ?? loanedOutFailure!)));
      return;
    }

    // Corrected: Explicitly cast empty lists to List<LoanEntity>
    final myLoans = myLoansResult.fold((_) => <LoanEntity>[], (loans) => loans);
    final loanedOutAssets = loanedOutAssetsResult.fold((_) => <LoanEntity>[], (loans) => loans);

    emit(AssetLoanDashboardLoaded(myLoans: myLoans, loanedOutAssets: loanedOutAssets));
  }

  Future<void> _onReturnLoan(ReturnLoanEvent event, Emitter<AssetLoanDashboardState> emit) async {
    emit(AssetLoanDashboardLoading());

    final result = await returnAssetUseCase(event.loanId);

    // Corrected: Removed 'await' before result.fold
    result.fold(
          (failure) => emit(AssetLoanDashboardError(_mapFailureToMessage(failure))),
          (_) {
        emit(LoanReturnSuccess(event.loanId));
        add(LoadLoans());
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      if (failure.message?.contains('Loan not found') ?? false) {
        return 'Loan not found.';
      } else if (failure.message?.contains('Unauthorized') ?? false) {
        return 'You are not authorized to perform this action.';
      }
      return failure.message ?? 'Unknown server error';
    } else if (failure is NetworkFailure) {
      return 'Network error';
    } else {
      return 'Unknown error';
    }
  }
}