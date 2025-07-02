import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecase/get_locale_usecase.dart';
import '../../domain/usecase/set_locale_usecase.dart';
import 'localization_event.dart';
import 'localization_state.dart';

class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  final GetLocaleUsecase getLocaleUsecase;
  final SetLocaleUsecase setLocaleUsecase;

  LocalizationBloc({required this.getLocaleUsecase, required this.setLocaleUsecase})
      : super(LocalizationInitial()) {
    on<GetInitialLocale>(_onGetInitialLocale);
    on<ChangeLocale>(_onChangeLocale);
  }

  Future<void> _onGetInitialLocale(GetInitialLocale event, Emitter<LocalizationState> emit) async {
    final languageCode = await getLocaleUsecase();
    emit(LocalizationLoaded(Locale(languageCode)));
  }

  Future<void> _onChangeLocale(ChangeLocale event, Emitter<LocalizationState> emit) async {
    await setLocaleUsecase(event.locale.languageCode);
    emit(LocalizationLoaded(event.locale));
  }
}