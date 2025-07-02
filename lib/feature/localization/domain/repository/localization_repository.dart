abstract class LocalizationRepository {
  Future<String> getLocale();
  Future<void> setLocale(String languageCode);
}