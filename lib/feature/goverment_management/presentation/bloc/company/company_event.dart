abstract class CompanyEvent {}

class CreateCompany extends CompanyEvent {
  final String name;
  final String? address;
  final String? industry;
  CreateCompany({required this.name, this.address, this.industry});
}

class FetchCompanies extends CompanyEvent {}

class DeleteCompany extends CompanyEvent {
  final int companyId;
  DeleteCompany({required this.companyId});
}

class UpdateCompany extends CompanyEvent {
  final int companyId;
  final String name;
  final String? address;
  final String? industry;
  UpdateCompany({required this.companyId, required this.name, this.address, this.industry});
}

class SwitchCompany extends CompanyEvent {
  final String companyId;
  final String companyName;
  final String rawRole;
  final bool canManageGovernmentAdmins;
  final bool canManageOperators;

  SwitchCompany({
    required this.companyId,
    required this.companyName,
    required this.rawRole,
    this.canManageGovernmentAdmins = false,
    this.canManageOperators = false,
  });
}
