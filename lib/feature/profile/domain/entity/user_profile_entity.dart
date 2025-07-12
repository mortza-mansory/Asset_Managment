import 'package:equatable/equatable.dart';

class SubscriptionPlanEntity extends Equatable {
  final String planType;
  final DateTime endDate;

  const SubscriptionPlanEntity({required this.planType, required this.endDate});

  @override
  List<Object> get props => [planType, endDate];
}


class UserProfileEntity extends Equatable {
  final int id;
  final String username; // Changed from fullName
  final String? email;
  final String? phoneNum; // Changed from phoneNumber
  final bool isActive;
  final SubscriptionPlanEntity? subscription;
  final String? role;
  final int? companyId;
  final String? companyName;
  final bool? canManageGovernmentAdmins;
  final bool? canManageOperators;

  const UserProfileEntity({
    required this.id,
    required this.username, // Changed from fullName
    this.email,
    this.phoneNum, // Changed from phoneNumber
    required this.isActive,
    this.subscription,
    this.role,
    this.companyId,
    this.companyName,
    this.canManageGovernmentAdmins,
    this.canManageOperators,
  });

  @override
  List<Object?> get props => [
    id,
    username, // Changed from fullName
    email,
    phoneNum, // Changed from phoneNumber
    isActive,
    subscription,
    role,
    companyId,
    companyName,
    canManageGovernmentAdmins,
    canManageOperators,
  ];
}