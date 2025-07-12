part of 'company_members_bloc.dart';

abstract class CompanyMembersState extends Equatable {
  const CompanyMembersState();

  @override
  List<Object> get props => [];
}

class CompanyMembersInitial extends CompanyMembersState {}

class CompanyMembersLoading extends CompanyMembersState {}

class CompanyMembersLoaded extends CompanyMembersState {
  final List<CompanyMemberEntity> members;
  final String currentUserRawRole; // Current user's role
  final bool currentUserCanManageGovernmentAdmins; // Current user's specific permission
  final bool currentUserCanManageOperators;       // Current user's specific permission

  const CompanyMembersLoaded({
    required this.members,
    required this.currentUserRawRole,
    required this.currentUserCanManageGovernmentAdmins,
    required this.currentUserCanManageOperators,
  });

  @override
  List<Object> get props => [
    members,
    currentUserRawRole,
    currentUserCanManageGovernmentAdmins,
    currentUserCanManageOperators,
  ];
}

class CompanyMembersActionSuccess extends CompanyMembersState {
  final String message;
  const CompanyMembersActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class CompanyMembersFailure extends CompanyMembersState {
  final String message;
  const CompanyMembersFailure({required this.message});

  @override
  List<Object> get props => [message];
}