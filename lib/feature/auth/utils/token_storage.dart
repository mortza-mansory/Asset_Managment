import 'package:get_storage/get_storage.dart';

class TokenStorage {
  final _box = GetStorage();
  static const _accessTokenKey = 'access_token';

  Future<void> saveAccessToken(String accessToken) async {
    await _box.write(_accessTokenKey, accessToken);
  }

  String? getAccessToken() {
    return _box.read<String>(_accessTokenKey);
  }

  Future<void> clearTokens() async {
    await _box.remove(_accessTokenKey);
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