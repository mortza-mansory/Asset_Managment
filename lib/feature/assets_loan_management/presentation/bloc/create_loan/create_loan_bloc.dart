import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/create_loan/create_loan_event.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/create_loan/create_loan_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/usecase/create_loan_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/usecase/get_asset_by_rfid_usecase.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';


class CreateLoanBloc extends Bloc<CreateLoanEvent, CreateLoanState> {
  final CreateLoanUseCase createLoanUseCase;
  final GetAssetByRfidUseCase getAssetByRfidUseCase;
  final SessionService sessionService;

  CreateLoanBloc({
    required this.createLoanUseCase,
    required this.getAssetByRfidUseCase,
    required this.sessionService,
  }) : super(CreateLoanInitial()) {
    on<CreateLoanSubmitted>(_onCreateLoanSubmitted);
    on<GetAssetDetailsById>(_onGetAssetDetailsById);
  }

  Future<void> _onCreateLoanSubmitted(CreateLoanSubmitted event, Emitter<CreateLoanState> emit) async {
    emit(CreateLoanLoading());

    final companyId = sessionService.getActiveCompany()?.id;
    if (companyId == null) {
      emit(const CreateLoanError('شناسه شرکت در دسترس نیست.'));
      return;
    }

    final loanRequest = LoanCreationRequestEntity(
      assetRfidTag: event.rfidTag, // Changed from assetId to rfidTag
      companyId: companyId,
      recipientId: event.recipientId == 0 ? null : event.recipientId, // Keep this logic for recipient
      externalRecipient: event.externalRecipient,
      phoneNumber: event.phoneNumber,
      endDate: event.endDate,
      details: event.details,
    );

    final result = await createLoanUseCase(loanRequest);

    result.fold(
          (failure) => emit(CreateLoanError(_mapFailureToMessage(failure))),
          (loan) => emit(CreateLoanSuccess(loan)),
    );
  }

  Future<void> _onGetAssetDetailsById(GetAssetDetailsById event, Emitter<CreateLoanState> emit) async {
    emit(CreateLoanLoading());

    final companyId = sessionService.getActiveCompany()?.id;
    if (companyId == null) {
      emit(const ScanFieldError('asset', 'شناسه شرکت در دسترس نیست.'));
      return;
    }

    final assetResult = await getAssetByRfidUseCase(event.assetRfid);

    await assetResult.fold(
          (failure) {
        emit(ScanFieldError('asset', _mapFailureToMessage(failure)));
      },
          (asset) {
        if (asset.companyId != companyId) {
          emit(const ScanFieldError('asset', 'این دارایی متعلق به شرکت شما نیست.'));
          return;
        }
        if (asset.status == 'ON_LOAN') {
          emit(const ScanFieldError('asset', 'این دارایی در حال حاضر امانت داده شده است.'));
          return;
        }
        // AssetDetailsLoaded now needs to carry the RFID tag
        emit(AssetDetailsLoaded(asset));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      if (failure.message?.contains('Asset not found') ?? false) {
        return 'دارایی یافت نشد.';
      } else if (failure.message?.contains('Asset is already on loan') ?? false) {
        return 'این دارایی در حال حاضر امانت داده شده است.';
      } else if (failure.message?.contains('Recipient user not found') ?? false) {
        return 'کاربر گیرنده یافت نشد.';
      } else if (failure.message?.contains('Unauthorized') ?? false) {
        return 'شما اجازه انجام این عملیات را ندارید.';
      }
      return failure.message ?? 'خطای سرور ناشناخته';
    } else if (failure is NetworkFailure) {
      return 'خطای شبکه';
    } else {
      return 'خطای ناشناخته';
    }
  }
}