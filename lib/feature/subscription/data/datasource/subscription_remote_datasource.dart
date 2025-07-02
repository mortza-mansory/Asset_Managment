import 'dart:convert';
import 'package:assetsrfid/core/constants/api_constatns.dart';
import 'package:http/http.dart' as http;
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/feature/auth/utils/token_storage.dart';
import 'package:assetsrfid/feature/subscription/data/models/subscription_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<SubscriptionResponseModel> createSubscription(SubscriptionCreateModel createModel);
  Future<bool> checkSubscriptionStatus(int companyId);
  Future<bool> hasActiveSubscription();

}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  SubscriptionRemoteDataSourceImpl({required this.client, required this.tokenStorage});

  @override
  Future<SubscriptionResponseModel> createSubscription(SubscriptionCreateModel createModel) async {
    final token =  tokenStorage.getAccessToken();
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/subscriptions/'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(createModel.toJson()),
    );
    if (response.statusCode == 200) {
      return SubscriptionResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<bool> hasActiveSubscription() async {
    final token = tokenStorage.getAccessToken();
    if (token == null) {
      throw  ServerException(message: 'Not Authenticated: Token is null.');
    }

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/subscriptions/status/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['has_active_subscription'] as bool;
    } else {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<bool> checkSubscriptionStatus(int companyId) async {
    final token =  tokenStorage.getAccessToken();
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/subscriptions/$companyId/status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['is_active'] as bool; // فرض بر اینکه پاسخ شامل is_active است
    } else {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

}