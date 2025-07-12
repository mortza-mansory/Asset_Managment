part of 'company_members_bloc.dart'; // Added this line

abstract class CompanyMembersEvent {}

class FetchCompanyMembers extends CompanyMembersEvent {}

class UpdateMemberRole extends CompanyMembersEvent {
  final int userId;
  final String newRole;
  final bool canManageGovernmentAdmins;
  final bool canManageOperators;

  UpdateMemberRole({
    required this.userId,
    required this.newRole,
    this.canManageGovernmentAdmins = false,
    this.canManageOperators = false,
  });
}

class RemoveMember extends CompanyMembersEvent {
  final int userId;

  RemoveMember({required this.userId});
}