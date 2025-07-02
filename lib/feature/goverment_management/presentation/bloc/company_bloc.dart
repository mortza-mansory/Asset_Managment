import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assetsrfid/feature/goverment_management/data/datasource/company_remote_datasource.dart';
import 'package:assetsrfid/feature/goverment_management/data/models/company_model.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_event.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CompanyRemoteDataSource dataSource;
  CompanyBloc({required this.dataSource}) : super(CompanyInitial()) {
    on<CreateCompany>(_onCreateCompany);
    on<FetchCompanies>(_onFetchCompanies);
    on<DeleteCompany>(_onDeleteCompany);
    on<UpdateCompany>(_onUpdateCompany);
  }

  void _onCreateCompany(CreateCompany event, Emitter<CompanyState> emit) async {
    emit(CompanyLoading());
    try {
      final model = CompanyCreateModel(name: event.name, address: event.address, industry: event.industry);
      final company = await dataSource.createCompany(model);
      emit(CompanyCreated(company: company));
    } catch (e) {
      emit(CompanyFailure(message: e.toString()));
    }
  }

  void _onFetchCompanies(FetchCompanies event, Emitter<CompanyState> emit) async {
    emit(CompanyLoading());
    try {
      final companies = await dataSource.fetchCompanies();
      emit(CompaniesLoaded(companies: companies));
    } catch (e) {
      emit(CompanyFailure(message: e.toString()));
    }
  }

  void _onDeleteCompany(DeleteCompany event, Emitter<CompanyState> emit) async {
    emit(CompanyLoading());
    try {
      await dataSource.deleteCompany(event.companyId);
      emit(CompanyDeleted(companyId: event.companyId));
    } catch (e) {
      emit(CompanyFailure(message: e.toString()));
    }
  }

  void _onUpdateCompany(UpdateCompany event, Emitter<CompanyState> emit) async {
    emit(CompanyLoading());
    try {
      final model = CompanyCreateModel(name: event.name, address: event.address, industry: event.industry);
      final company = await dataSource.updateCompany(event.companyId, model);
      emit(CompanyUpdated(company: company));
    } catch (e) {
      emit(CompanyFailure(message: e.toString()));
    }
  }
}