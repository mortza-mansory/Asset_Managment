import '../repository/localization_repository.dart';

class SetLocaleUsecase {
  final LocalizationRepository repository;
  SetLocaleUsecase(this.repository);

  Future<void> call(String languageCode) async {
    await repository.setLocale(languageCode);
  }
}