class CompanyModel {
  final int id;
  final String name;
  final String role;
  final String? address;
  final String? industry;

  CompanyModel({
    required this.id,
    required this.name,
    required this.role,
    this.address,
    this.industry,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'],
      name: json['name'],
      role: json['role'] ?? 'Member',
      address: json['address'],
      industry: json['industry'],
    );
  }
}

class CompanyCreateModel {
  final String name;
  final String? address;
  final String? industry;

  CompanyCreateModel({required this.name, this.address, this.industry});
  Map<String, dynamic> toJson() => {
    'name': name,
    if (address != null) 'address': address,
    if (industry != null) 'industry': industry,
  };
}