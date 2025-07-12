part of 'invitation_bloc.dart';

abstract class InvitationEvent extends Equatable {
  const InvitationEvent();

  @override
  List<Object?> get props => [];
}

class SendInvitation extends InvitationEvent {
  final String identifier;
  final String role;
  final bool canManageGovernmentAdmins;
  final bool canManageOperators;

  const SendInvitation({
    required this.identifier,
    required this.role,
    this.canManageGovernmentAdmins = false,
    this.canManageOperators = false,
  });

  @override
  List<Object?> get props => [identifier, role, canManageGovernmentAdmins, canManageOperators];
}

class FetchMyInvitations extends InvitationEvent {}

class RespondToInvitation extends InvitationEvent {
  final String token;
  final bool accept;

  const RespondToInvitation({required this.token, required this.accept});

  @override
  List<Object?> get props => [token, accept];
}