import 'package:equatable/equatable.dart';

class SubscriptionPlanEntity extends Equatable {
  final String planType;
  final DateTime endDate;

  const SubscriptionPlanEntity({required this.planType, required this.endDate});

  @override
  List<Object> get props => [planType, endDate];
}

class UserProfileEntity extends Equatable {
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final bool isActive;
  final SubscriptionPlanEntity? subscription;

  const UserProfileEntity({
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.isActive,
    this.subscription,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber, isActive, subscription];
}