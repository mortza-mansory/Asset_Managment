import 'package:assetsrfid/feature/goverment_management/domain/entities/company_member_entity.dart';

class CompanyMemberModel extends CompanyMemberEntity {
  const CompanyMemberModel({
    required super.userId,
    required super.username,
    super.email,
    required super.role,
    required super.status,
    required super.joinedAt,
    super.invitedBy,
    super.canManageGovernmentAdmins, // Added to constructor
    super.canManageOperators,       // Added to constructor
  });

  factory CompanyMemberModel.fromJson(Map<String, dynamic> json) {
    return CompanyMemberModel(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      invitedBy: json['invited_by'] as String?,
      canManageGovernmentAdmins: json['can_manage_government_admins'] as bool?, // Parsed from JSON
      canManageOperators: json['can_manage_operators'] as bool?,       // Parsed from JSON
    );
  }
}