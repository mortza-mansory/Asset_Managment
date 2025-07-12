// lib/core/services/session_service.dart

import 'package:get_storage/get_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ActiveCompany {
  final int id;
  final String name;
  final String role;
  final bool canManageGovernmentAdmins; // اضافه شده
  final bool canManageOperators; // اضافه شده

  ActiveCompany({
    required this.id,
    required this.name,
    required this.role,
    required this.canManageGovernmentAdmins,
    required this.canManageOperators,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'can_manage_government_admins': canManageGovernmentAdmins,
    'can_manage_operators': canManageOperators,
  };
  factory ActiveCompany.fromJson(Map<String, dynamic> json) {

    return ActiveCompany(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      canManageGovernmentAdmins: json['can_manage_government_admins'] ?? false,
      canManageOperators: json['can_manage_operators'] ?? false,
    );
  }
}

class SessionService {
  final _box = GetStorage();

  static const _tokenKey = 'access_token';
  static const _usernameKey = 'username';
  static const _activeCompanyKey = 'active_company';
  static const String _kBulkUploadBannerSeenKey = 'has_seen_bulk_upload_banner'; // New key for the banner

  int? getUserId() {
    final token = getAccessToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final userIdStr = decodedToken['sub'];
      return userIdStr != null ? int.tryParse(userIdStr.toString()) : null;
    }
    return null;
  }

  // New method to get the username from the access token
  String? getUsername() {
    final token = getAccessToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      // Assuming 'username' is the key in your JWT payload for the username
      return decodedToken['username'] as String?;
    }
    return null;
  }


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
    await _box.remove(_kBulkUploadBannerSeenKey); // Clear banner status on session clear
  }

  // New methods for bulk upload banner visibility using GetStorage
  Future<void> markBulkUploadBannerAsSeen() async {
    await _box.write(_kBulkUploadBannerSeenKey, true);
  }

  bool hasSeenBulkUploadBanner() {
    return _box.read<bool>(_kBulkUploadBannerSeenKey) ?? false;
  }
}