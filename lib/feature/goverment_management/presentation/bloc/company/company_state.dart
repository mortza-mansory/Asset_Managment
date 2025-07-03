import 'package:assetsrfid/feature/goverment_management/data/models/company_model.dart';

abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyCreated extends CompanyState {
  final CompanyModel company;
  CompanyCreated({required this.company});
}

class CompanyFailure extends CompanyState {
  final String message;
  CompanyFailure({required this.message});
}

class CompaniesLoaded extends CompanyState {
  final List<CompanyModel> companies;
  CompaniesLoaded({required this.companies});
}

class CompanyDeleted extends CompanyState {
  final int companyId;
  CompanyDeleted({required this.companyId});
}

class CompanyUpdated extends CompanyState {
  final CompanyModel company;
  CompanyUpdated({required this.company});
}

class CompanySwitchInProgress extends CompanyState {
  final String companyId;
  CompanySwitchInProgress({required this.companyId});
}

class CompanySwitchSuccess extends CompanyState {
  final String companyName;
  CompanySwitchSuccess({required this.companyName});
}