import '../repository/localization_repository.dart';

class GetLocaleUsecase {
  final LocalizationRepository repository;
  GetLocaleUsecase(this.repository);

  Future<String> call() async {
    return await repository.getLocale();
  }
}