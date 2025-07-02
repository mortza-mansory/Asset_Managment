import '../local_data/localization_local_datasource.dart';
import '../../domain/repository/localization_repository.dart';

class LocalizationRepositoryImpl implements LocalizationRepository {
  final LocalizationLocalDataSource localDataSource;

  LocalizationRepositoryImpl({required this.localDataSource});

  @override
  Future<String> getLocale() async {
    final locale = await localDataSource.getLocale();
    return locale ?? 'en';
  }

  @override
  Future<void> setLocale(String languageCode) async {
    await localDataSource.setLocale(languageCode);
  }
}