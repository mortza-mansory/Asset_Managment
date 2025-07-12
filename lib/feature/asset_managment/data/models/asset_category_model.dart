class AssetCategoryModel {
  final int id;
  final String name;
  final int code;
  final String? description;
  final String? icon_name;
  final String? color_hex;

  AssetCategoryModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.icon_name,
    this.color_hex,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'icon_name': icon_name,
      'color_hex': color_hex,
    };
  }
  factory AssetCategoryModel.fromJson(Map<String, dynamic> json) {
    return AssetCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as int,
      description: json['description'] as String?,
      icon_name: json['icon_name'] as String?,
      color_hex: json['color_hex'] as String?,
    );
  }
}