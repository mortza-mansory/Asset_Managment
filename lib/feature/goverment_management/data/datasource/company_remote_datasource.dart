import 'dart:convert';
import 'package:assetsrfid/core/constants/api_constatns.dart';
import 'package:http/http.dart' as http;
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/feature/auth/utils/token_storage.dart';
import 'package:assetsrfid/feature/goverment_management/data/models/company_model.dart';

abstract class CompanyRemoteDataSource {
  Future<CompanyModel> createCompany(CompanyCreateModel createModel);
  Future<List<CompanyModel>> fetchCompanies();
  Future<void> deleteCompany(int companyId);
  Future<CompanyModel> updateCompany(int companyId, CompanyCreateModel updateModel);
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;
  CompanyRemoteDataSourceImpl({required this.client, required this.tokenStorage});

  @override
  Future<CompanyModel> createCompany(CompanyCreateModel createModel) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/companies/'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(createModel.toJson()),
    );
    if (response.statusCode == 200) {
      return CompanyModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<List<CompanyModel>> fetchCompanies() async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/companies/?page=1&per_page=100'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => CompanyModel.fromJson(item)).toList();
    } else {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<void> deleteCompany(int companyId) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/companies/$companyId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<CompanyModel> updateCompany(int companyId, CompanyCreateModel updateModel) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/companies/$companyId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(updateModel.toJson()),
    );
    if (response.statusCode == 200) {
      return CompanyModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }
}