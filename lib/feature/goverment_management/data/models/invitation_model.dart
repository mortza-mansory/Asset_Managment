import 'package:assetsrfid/feature/goverment_management/domain/entities/invitation_entity.dart';

class InvitationModel extends InvitationEntity {
  const InvitationModel({
    required super.token,
    required super.companyName,
    required super.invitedBy,
    required super.roleToGrant,
    required super.expiresAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      token: json['token'],
      companyName: json['company_name'],
      invitedBy: json['invited_by'],
      roleToGrant: json['role_to_grant'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}