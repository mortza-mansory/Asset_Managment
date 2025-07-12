// lib/feature/profile/data/model/user_profile_model.dart

import 'package:assetsrfid/feature/profile/domain/entity/user_profile_entity.dart';
import 'package:assetsrfid/feature/subscription/data/models/subscription_model.dart';
import 'package:equatable/equatable.dart';

// Assuming SubscriptionPlanModel extends SubscriptionEntity
class SubscriptionPlanModel extends SubscriptionPlanEntity {
  const SubscriptionPlanModel({required super.planType, required super.endDate});

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      planType: json['plan_type'] as String, // Ensure type safety
      endDate: DateTime.parse(json['end_date'] as String), // Ensure type safety
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'plan_type': planType,
      'end_date': endDate.toIso8601String(),
    };
  }
}

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id, // Required from UserProfileEntity
    required super.username, // Changed from fullName
    super.email,
    super.phoneNum, // Changed from phoneNumber
    required super.isActive,
    super.subscription,
    super.role,
    super.companyId,
    super.companyName,
    super.canManageGovernmentAdmins,
    super.canManageOperators,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int? ?? 0, // Corrected: Safely parse 'id' with a default of 0 if null
      username: json['username'] as String, // Changed from fullName
      email: json['email'] as String?,
      phoneNum: json['phone_num'] as String?, // Changed from phoneNumber
      isActive: json['is_active'] as bool,
      subscription: json['subscription'] != null
          ? SubscriptionPlanModel.fromJson(json['subscription'] as Map<String, dynamic>)
          : null,
      role: json['role'] as String?,
      companyId: json['company_id'] as int?,
      companyName: json['company_name'] as String?,
      canManageGovernmentAdmins: json['can_manage_government_admins'] as bool?,
      canManageOperators: json['can_manage_operators'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone_num': phoneNum,
      'is_active': isActive,
      'subscription': (subscription as SubscriptionPlanModel?)?.toJson(), // Cast to specific model for toJson
      'role': role,
      'company_id': companyId,
      'company_name': companyName,
      'can_manage_government_admins': canManageGovernmentAdmins,
      'can_manage_operators': canManageOperators,
    };
  }
}