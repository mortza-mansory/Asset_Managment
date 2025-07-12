part of 'invitation_bloc.dart';

abstract class InvitationState extends Equatable {
  const InvitationState();
  @override
  List<Object?> get props => [];
}

class InvitationInitial extends InvitationState {}
class InvitationInProgress extends InvitationState {}

class InvitationActionSuccess extends InvitationState {
  final String message;
  const InvitationActionSuccess({required this.message});
}
class InvitationFailure extends InvitationState {
  final String message;
  const InvitationFailure({required this.message});
}
class InvitationRequiresOtp extends InvitationState {
  final String tempToken;
  const InvitationRequiresOtp({required this.tempToken});
}
class MyInvitationsLoading extends InvitationState {}
class MyInvitationsLoaded extends InvitationState {
  final List<InvitationEntity> invitations;
  const MyInvitationsLoaded({required this.invitations});
}
class MyInvitationsFailure extends InvitationState {
  final String message;
  const MyInvitationsFailure({required this.message});
}