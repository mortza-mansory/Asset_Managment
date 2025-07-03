part of 'company_settings_bloc.dart';

abstract class CompanySettingsState extends Equatable {
  const CompanySettingsState();
  @override
  List<Object> get props => [];
}

class CompanySettingsInitial extends CompanySettingsState {}

class CompanySettingsLoading extends CompanySettingsState {}

class CompanyOverviewLoaded extends CompanySettingsState {
  final CompanyOverviewEntity overview;
  const CompanyOverviewLoaded({required this.overview});
  @override
  List<Object> get props => [overview];
}

class CompanySettingsFailure extends CompanySettingsState {
  final String message;
  const CompanySettingsFailure({required this.message});
  @override
  List<Object> get props => [message];
}