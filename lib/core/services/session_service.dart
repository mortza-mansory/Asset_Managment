import 'package:get_storage/get_storage.dart';

// مدل ساده برای نگهداری اطلاعات شرکت فعال
class ActiveCompany {
  final int id;
  final String name;
  final String role;

  ActiveCompany({required this.id, required this.name, required this.role});

  // متدهایی برای تبدیل به Map و برعکس برای ذخیره‌سازی
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'role': role};
  factory ActiveCompany.fromJson(Map<String, dynamic> json) {
    return ActiveCompany(id: json['id'], name: json['name'], role: json['role']);
  }
}

class SessionService {
  final _box = GetStorage();

  static const _tokenKey = 'access_token';
  static const _usernameKey = 'username';
  static const _activeCompanyKey = 'active_company';

  Future<void> saveAccessToken(String token) => _box.write(_tokenKey, token);
  String? getAccessToken() => _box.read<String>(_tokenKey);

  bool get isLoggedIn => getAccessToken() != null;


  Future<void> updateUserSession(String newUsername) async {
    final oldUsername = _box.read<String>(_usernameKey);

    if (oldUsername != newUsername) {
      await _box.write(_usernameKey, newUsername);
      await clearActiveCompany();
    }
  }

  Future<void> saveActiveCompany(ActiveCompany company) => _box.write(_activeCompanyKey, company.toJson());
  Future<void> clearActiveCompany() => _box.remove(_activeCompanyKey);
  ActiveCompany? getActiveCompany() {
    final json = _box.read<Map<String, dynamic>>(_activeCompanyKey);
    if (json != null) {
      return ActiveCompany.fromJson(json);
    }
    return null;
  }

  Future<void> clearSession() async {
    await _box.remove(_tokenKey);
    await _box.remove(_usernameKey);
    await _box.remove(_activeCompanyKey);
    // در آینده PermissionService هم اینجا پاک می‌شود
  }
}