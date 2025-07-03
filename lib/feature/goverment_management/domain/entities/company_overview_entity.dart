import 'package:equatable/equatable.dart';

class CompanyOverviewEntity extends Equatable {
  final int id;
  final String name;
  final bool isActive;
  final int userCount;
  final int assetsCount;

  const CompanyOverviewEntity({
    required this.id,
    required this.name,
    required this.isActive,
    required this.userCount,
    required this.assetsCount,
  });

  @override
  List<Object> get props => [id, name, isActive, userCount, assetsCount];
}