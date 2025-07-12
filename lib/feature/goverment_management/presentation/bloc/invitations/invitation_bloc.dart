import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:assetsrfid/core/di/app_providers.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/goverment_management/domain/entities/invitation_entity.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/send_invitation_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/fetch_my_invitations_usecase.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/respond_to_invitation_usecase.dart';
import 'package:assetsrfid/core/error/failures.dart'; // Added missing import for Failure

part 'invitation_event.dart';
part 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final SendInvitationUseCase _sendInvitationUseCase;
  final FetchMyInvitationsUseCase _fetchMyInvitationsUseCase;
  final RespondToInvitationUseCase _respondToInvitationUseCase;
  final SessionService _sessionService = getIt<SessionService>();

  InvitationBloc({
    required SendInvitationUseCase sendInvitationUseCase,
    required FetchMyInvitationsUseCase fetchMyInvitationsUseCase,
    required RespondToInvitationUseCase respondToInvitationUseCase,
  })  : _sendInvitationUseCase = sendInvitationUseCase,
        _fetchMyInvitationsUseCase = fetchMyInvitationsUseCase,
        _respondToInvitationUseCase = respondToInvitationUseCase,
        super(InvitationInitial()) {
    on<SendInvitation>(_onSendInvitation);
    on<FetchMyInvitations>(_onFetchMyInvitations);
    on<RespondToInvitation>(_onRespondToInvitation);
    // Removed duplicate on<SendInvitation>(_onSendInvitation);
  }

  Future<void> _onSendInvitation(SendInvitation event, Emitter<InvitationState> emit) async {
    emit(InvitationInProgress());
    final companyId = _sessionService.getActiveCompany()?.id;
    if (companyId == null) {
      emit(const InvitationFailure(message: 'No active company found'));
      return;
    }
    final result = await _sendInvitationUseCase( // Corrected to use _sendInvitationUseCase
      companyId: companyId,
      identifier: event.identifier,
      role: event.role,
      canManageGovernmentAdmins: event.canManageGovernmentAdmins,
      canManageOperators: event.canManageOperators,
    );

    result.fold(
          (failure) => emit(InvitationFailure(message: _mapFailureToMessage(failure))), // Use _mapFailureToMessage
          (response) {
        if (response['otp_required'] == true) {
          emit(InvitationRequiresOtp(tempToken: response['temp_token']));
        } else {
          emit(const InvitationActionSuccess(message: 'Invitation sent successfully!'));
        }
      },
    );
  }

  Future<void> _onFetchMyInvitations(FetchMyInvitations event, Emitter<InvitationState> emit) async {
    emit(MyInvitationsLoading());
    final result = await _fetchMyInvitationsUseCase();
    result.fold(
          (failure) => emit(MyInvitationsFailure(message: _mapFailureToMessage(failure))), // Use _mapFailureToMessage
          (invitations) => emit(MyInvitationsLoaded(invitations: invitations)),
    );
  }

  Future<void> _onRespondToInvitation(RespondToInvitation event, Emitter<InvitationState> emit) async {
    // You might want to add InvitationInProgress() here
    final result = await _respondToInvitationUseCase(token: event.token, accept: event.accept);
    result.fold(
          (failure) => emit(MyInvitationsFailure(message: _mapFailureToMessage(failure))), // Use _mapFailureToMessage
          (_) => emit(const InvitationActionSuccess(message: 'Response submitted.')),
    );
  }

  String _mapFailureToMessage(Failure failure) { // Added missing _mapFailureToMessage
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      default:
        return 'Unexpected error occurred';
    }
  }
}