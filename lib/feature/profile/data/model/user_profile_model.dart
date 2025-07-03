import 'package:assetsrfid/feature/profile/domain/entity/user_profile_entity.dart';

class SubscriptionPlanModel extends SubscriptionPlanEntity {
  const SubscriptionPlanModel({required super.planType, required super.endDate});

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      planType: json['plan_type'] ?? '',
      endDate: DateTime.parse(json['end_date']),
    );
  }
}

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.fullName,
    super.email,
    super.phoneNumber,
    required super.isActive,
    super.subscription,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      fullName: json['username'] ?? 'Unnamed User',
      email: json['email'],
      phoneNumber: json['phone_num'],
      isActive: json['is_active'] ?? false,
      subscription: json['subscription'] != null
          ? SubscriptionPlanModel.fromJson(json['subscription'])
          : null,
    );
  }
}