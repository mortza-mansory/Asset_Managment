import 'package:assetsrfid/feature/goverment_management/domain/entities/company_overview_entity.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:assetsrfid/core/di/app_providers.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:assetsrfid/feature/goverment_management/domain/usecase/get_company_overview_usecase.dart';

part 'company_settings_event.dart';
part 'company_settings_state.dart';

class CompanySettingsBloc extends Bloc<CompanySettingsEvent, CompanySettingsState> {
  final GetCompanyOverviewUseCase _getCompanyOverviewUseCase;
  final SessionService _sessionService = getIt<SessionService>();

  CompanySettingsBloc({required GetCompanyOverviewUseCase getCompanyOverviewUseCase})
      : _getCompanyOverviewUseCase = getCompanyOverviewUseCase,
        super(CompanySettingsInitial()) {
    on<LoadCompanyOverview>(_onLoadCompanyOverview);
  }

  Future<void> _onLoadCompanyOverview(
      LoadCompanyOverview event,
      Emitter<CompanySettingsState> emit,
      ) async {
    emit(CompanySettingsLoading());
    final company = _sessionService.getActiveCompany();
    if (company == null) {
      emit(const CompanySettingsFailure(message: 'شرکت فعالی یافت نشد.'));
      return;
    }

    final result = await _getCompanyOverviewUseCase(company.id);
    result.fold(
          (failure) => emit(CompanySettingsFailure(message: failure.message)),
          (overview) => emit(CompanyOverviewLoaded(overview: overview)),
    );
  }
}