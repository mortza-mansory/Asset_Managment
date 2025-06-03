import 'package:get_storage/get_storage.dart';

class TokenStorage {
  final box = GetStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await box.write(_accessTokenKey, accessToken);
    await box.write(_refreshTokenKey, refreshToken);
  }

  String? getAccessToken() => box.read(_accessTokenKey);

  String? getRefreshToken() => box.read(_refreshTokenKey);

  Future<void> clearTokens() async {
    await box.remove(_accessTokenKey);
    await box.remove(_refreshTokenKey);
  }
}


// import 'package:shared_preferences/shared_preferences.dart';
//
// class TokenStorage {
//   static const String _accessTokenKey = 'access_token';
//   static const String _refreshTokenKey = 'refresh_token';
//
//   Future<void> saveTokens({
//     required String accessToken,
//     required String refreshToken,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_accessTokenKey, accessToken);
//     await prefs.setString(_refreshTokenKey, refreshToken);
//   }
//
//   Future<String?> getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_accessTokenKey);
//   }
//
//   Future<String?> getRefreshToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_refreshTokenKey);
//   }
//
//   Future<void> clearTokens() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_accessTokenKey);
//     await prefs.remove(_refreshTokenKey);
//   }
// }