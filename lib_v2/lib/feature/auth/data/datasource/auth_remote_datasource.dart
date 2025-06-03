import 'dart:convert';
import 'package:assetsrfid/feature/auth/data/models/login_response_model.dart';
import 'package:assetsrfid/feature/auth/data/models/sign_up_response_model.dart';
import 'package:assetsrfid/feature/auth/data/models/token_response_model.dart';
import 'package:http/http.dart' as http;

abstract class AuthRemoteDataSource {
  Future<SignUpResponseModel> signUp({
    required String username,
    required String password,
    required String phoneNumber,
    String? governmentId,
    String? governmentName,
  });

  Future<LoginResponseModel> login({
    required String username,
    required String password,
  });

  Future<TokenResponseModel> verifyOtp({
    required String tempToken,
    required String otp,
  });

  Future<bool> verifyAccessToken(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'http://localhost:8000/api/v1';

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<SignUpResponseModel> signUp({
    required String username,
    required String password,
    required String phoneNumber,
    String? governmentId,
    String? governmentName,
  }) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'phone_number': phoneNumber,
        if (governmentId != null) 'government_id': governmentId,
        if (governmentName != null) 'government_name': governmentName,
      }),
    );

    if (response.statusCode == 200) {
      return SignUpResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to sign up: ${response.body}');
    }
  }

  @override
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  @override
  Future<TokenResponseModel> verifyOtp({
    required String tempToken,
    required String otp,
  }) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'temp_token': tempToken,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return TokenResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to verify OTP: ${response.body}');
    }
  }

  @override
  Future<bool> verifyAccessToken(String accessToken) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/verify-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'access_token': accessToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['valid'] == true;
    } else {
      throw Exception('Failed to verify token: ${response.body}');
    }
  }
}