// assetsrfid/lib/feature/asset_managment/domain/entities/asset_category_entity.dart

import 'package:assetsrfid/feature/asset_managment/data/models/asset_category_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // For IconData, Color

class AssetCategoryEntity extends Equatable {
  final int id;
  final String name;
  final int code;
  final String? description;
  final String? iconName; // e.g., "laptop_mac_outlined"
  final String? colorHex; // e.g., "#42A5F5"

  const AssetCategoryEntity({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.iconName,
    this.colorHex,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    description,
    iconName,
    colorHex,
  ];

  // Helper method to convert AssetCategoryModel (DTO) to AssetCategoryEntity
  factory AssetCategoryEntity.fromResponse(AssetCategoryModel model) { // Changed parameter type to AssetCategoryModel
    return AssetCategoryEntity(
      id: model.id,
      name: model.name,
      code: model.code,
      description: model.description,
      iconName: model.icon_name,
      colorHex: model.color_hex,
    );
  }

  // Helper method to convert color hex string to Color object
  Color? get color {
    if (colorHex == null) return null;
    String hexColor = colorHex!.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor; // Add FF for opacity
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // Helper method to convert icon name string to IconData object
  IconData? get icon {
    if (iconName == null) return null;
    // This is a simplified mapping. In a real app, you might have a comprehensive map
    // or a custom font icon solution.
    switch (iconName) {
      case 'laptop_mac_outlined': return Icons.laptop_mac_outlined;
      case 'chair_outlined': return Icons.chair_outlined;
      case 'build_outlined': return Icons.build_outlined;
      case 'desktop_windows_outlined': return Icons.desktop_windows_outlined;
      case 'table_restaurant_outlined': return Icons.table_restaurant_outlined;
      case 'directions_car_outlined': return Icons.directions_car_outlined;
      case 'storage_outlined': return Icons.storage_outlined;
      case 'gavel_outlined': return Icons.gavel_outlined;
      case 'category_outlined': return Icons.category_outlined;
    // Add more cases for other icons you plan to use and store
      default: return null; // Or a default fallback icon
    }
  }
}