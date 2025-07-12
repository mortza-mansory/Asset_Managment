import 'package:equatable/equatable.dart';

class CompanyMemberEntity extends Equatable {
  final int userId;
  final String username;
  final String? email;
  final String role;
  final String status;
  final DateTime joinedAt;
  final String? invitedBy;
  final bool? canManageGovernmentAdmins; // Added
  final bool? canManageOperators;       // Added

  const CompanyMemberEntity({
    required this.userId,
    required this.username,
    this.email,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.invitedBy,
    this.canManageGovernmentAdmins, // Added to constructor
    this.canManageOperators,       // Added to constructor
  });

  @override
  List<Object?> get props => [
    userId,
    username,
    email,
    role,
    status,
    joinedAt,
    invitedBy,
    canManageGovernmentAdmins, // Added to props
    canManageOperators,       // Added to props
  ];
}