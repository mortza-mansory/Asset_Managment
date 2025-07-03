import 'dart:convert';
import 'package:assetsrfid/core/constants/api_constatns.dart';
import 'package:http/http.dart' as http;
import 'package:assetsrfid/core/di/app_providers.dart';
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/feature/auth/utils/token_storage.dart';
import 'package:assetsrfid/feature/profile/data/model/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage = getIt<TokenStorage>();

  ProfileRemoteDataSourceImpl({required this.client});

  @override
  Future<UserProfileModel> getUserProfile() async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) {
      throw  ServerException(message: 'Token not found');
    }

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw ServerException(message: 'Failed to load user profile: ${response.statusCode}');
    }
  }
}