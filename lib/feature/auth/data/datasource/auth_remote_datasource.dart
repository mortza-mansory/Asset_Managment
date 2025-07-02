import 'dart:convert';
import 'package:assetsrfid/core/constants/api_constatns.dart';
import 'package:http/http.dart' as http;
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/feature/auth/data/models/auth_req_models.dart';
import 'package:assetsrfid/feature/auth/data/models/auth_res_models.dart';

abstract class AuthRemoteDataSource {
  Future<SignUpResponseModel> signup(SignUpRequestModel requestModel);
  Future<LoginResponseModel> login(String username, String password);
  Future<TokenResponseModel> verifyLoginOtp(VerifyOtpRequestModel requestModel);
  Future<ResetCodeResponseModel> requestResetCode(String identifier);
  Future<void> verifyResetCode({required int userId, required String code, required String newPassword});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<SignUpResponseModel> signup(SignUpRequestModel requestModel) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestModel.toJson()),
    );
    if (response.statusCode == 200) {
      return SignUpResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<LoginResponseModel> login(String username, String password) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login?username=$username&password=$password'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );
    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<TokenResponseModel> verifyLoginOtp(VerifyOtpRequestModel requestModel) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/verify-login-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestModel.toJson()),
    );
    if (response.statusCode == 200) {
      print(TokenResponseModel.fromJson(jsonDecode(response.body)).toString());
      return TokenResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<ResetCodeResponseModel> requestResetCode(String identifier) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/reset-password?identifier=$identifier'),
    );
    if (response.statusCode == 200) {
      return ResetCodeResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<void> verifyResetCode({required int userId, required String code, required String newPassword}) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/verify-reset-code?user_id=$userId&code=$code&new_password=$newPassword'),
    );
    if (response.statusCode != 200) {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }
}