part of 'company_settings_bloc.dart';

abstract class CompanySettingsEvent extends Equatable {
  const CompanySettingsEvent();
  @override
  List<Object> get props => [];
}

class LoadCompanyOverview extends CompanySettingsEvent {}