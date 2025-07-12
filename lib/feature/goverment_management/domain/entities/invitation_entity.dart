import 'package:equatable/equatable.dart';

class InvitationEntity extends Equatable {
  final String token;
  final String companyName;
  final String invitedBy;
  final String roleToGrant;
  final DateTime expiresAt;

  const InvitationEntity({
    required this.token,
    required this.companyName,
    required this.invitedBy,
    required this.roleToGrant,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [token, companyName, invitedBy, roleToGrant, expiresAt];
}