
abstract class LocalizationLocalDataSource {
  Future<String?> getLocale();
  Future<void> setLocale(String languageCode);
}

class LocalizationLocalDataSourceImpl implements LocalizationLocalDataSource {
  String? _cachedLocale;

  LocalizationLocalDataSourceImpl();

  @override
  Future<String?> getLocale() async {
    return _cachedLocale;
  }

  @override
  Future<void> setLocale(String languageCode) async {
    _cachedLocale = languageCode;
  }
}
// //import 'package:shared_preferences/shared_preferences.dart';
//
// abstract class LocalizationLocalDataSource {
//   Future<String?> getLocale();
//   Future<void> setLocale(String languageCode);
// }
//
// class LocalizationLocalDataSourceImpl implements LocalizationLocalDataSource {
//   //final SharedPreferences sharedPreferences;
//   static const String _localeKey = 'locale';
//
//  // LocalizationLocalDataSourceImpl({required this.sharedPreferences});
//   LocalizationLocalDataSourceImpl();
//
//   @override
//   Future<String?> getLocale() async {
//   //  return sharedPreferences.getString(_localeKey);
//     return _localeKey;
//   }
//
//   @override
//   Future<void> setLocale(String languageCode) async {
//     //await sharedPreferences.setString(_localeKey, languageCode);
//   }
// }