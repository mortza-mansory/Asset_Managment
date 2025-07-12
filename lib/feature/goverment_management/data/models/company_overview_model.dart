import 'package:assetsrfid/feature/goverment_management/domain/entities/company_overview_entity.dart';

class CompanyOverviewModel extends CompanyOverviewEntity {
  const CompanyOverviewModel({
    required super.id,
    required super.name,
    required super.isActive,
    required super.userCount,
    required super.assetsCount,
  });

  factory CompanyOverviewModel.fromJson(Map<String, dynamic> json) {
    return CompanyOverviewModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      isActive: json['is_active'] ?? false,
      userCount: json['user_count'] ?? 0,
      assetsCount: json['assets_count'] ?? 0,
    );
  }
}
