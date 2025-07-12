import 'dart:convert';
import 'package:assetsrfid/core/constants/api_constatns.dart';
import 'package:assetsrfid/feature/goverment_management/data/models/company_member_model.dart';
import 'package:assetsrfid/feature/goverment_management/data/models/company_overview_model.dart';
import 'package:assetsrfid/feature/goverment_management/data/models/invitation_model.dart';
import 'package:http/http.dart' as http;
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/feature/auth/utils/token_storage.dart';
import 'package:assetsrfid/feature/goverment_management/data/models/company_model.dart';

abstract class CompanyRemoteDataSource {
  Future<CompanyModel> createCompany(CompanyCreateModel createModel);
  Future<List<CompanyModel>> fetchCompanies();
  Future<void> deleteCompany(int companyId);
  Future<CompanyModel> updateCompany(int companyId, CompanyCreateModel updateModel);
  Future<CompanyOverviewModel> getCompanyOverview(int companyId);

  Future<List<CompanyMemberModel>> getCompanyMembers(int companyId);
  Future<void> updateMemberRole(int companyId, int userId, String newRole, {
    required bool canManageGovernmentAdmins, // Added
    required bool canManageOperators,       // Added
  });
  Future<void> removeMember(int companyId, int userId);

  Future<Map<String, dynamic>> sendInvitation(int companyId, String identifier, String role, {
    required bool canManageGovernmentAdmins, // Added
    required bool canManageOperators,       // Added
  });
  Future<List<InvitationModel>> getMyInvitations();
  Future<void> respondToInvitation(String token, bool accept);

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

  @override
  Future<CompanyOverviewModel> getCompanyOverview(int companyId) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/companies/$companyId/overview'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return CompanyOverviewModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw ServerException(message: 'Failed to load company overview: ${response.statusCode}');
    }
  }
  @override
  Future<List<CompanyMemberModel>> getCompanyMembers(int companyId) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/companies/$companyId/members'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => CompanyMemberModel.fromJson(item)).toList();
    } else {
      throw ServerException(message: 'Failed to load company members');
    }
  }
  @override
  Future<void> updateMemberRole(int companyId, int userId, String newRole, {
    required bool canManageGovernmentAdmins, // Added
    required bool canManageOperators,       // Added
  }) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final response = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/companies/$companyId/members/$userId/role'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'role': newRole,
        'can_manage_government_admins': canManageGovernmentAdmins, // Passed to backend
        'can_manage_operators': canManageOperators,               // Passed to backend
      }),
    );

    if (response.statusCode != 200) {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<void> removeMember(int companyId, int userId) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/companies/$companyId/members/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }

  @override
  Future<Map<String, dynamic>> sendInvitation(int companyId, String identifier, String role, {
    required bool canManageGovernmentAdmins, // Added
    required bool canManageOperators,       // Added
  }) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final body = jsonEncode({
      'identifier': identifier,
      'role': role,
      'can_manage_government_admins': canManageGovernmentAdmins, // Passed to backend
      'can_manage_operators': canManageOperators,               // Passed to backend
    });
    print('Request body: $body');

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/invitations/for-company/$companyId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: body,
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 201) {
      return responseBody;
    } else {
      String errorMessage;
      if (responseBody['detail'] is String) {
        errorMessage = responseBody['detail'];
      } else if (responseBody['detail'] is List) {
        errorMessage = (responseBody['detail'] as List)
            .map((error) => error['msg'])
            .join('; ');
      } else {
        errorMessage = 'Unknown error occurred';
      }
      throw ServerException(message: errorMessage);
    }
  }
  @override
  Future<List<InvitationModel>> getMyInvitations() async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/invitations/my'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => InvitationModel.fromJson(item)).toList();
    } else {
      throw ServerException(message: 'Failed to load invitations');
    }
  }

  @override
  Future<void> respondToInvitation(String token, bool accept) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null) throw ServerException(message: 'Not authenticated');

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/invitations/$token/respond'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
      body: jsonEncode({'accept': accept}),
    );

    if (response.statusCode != 200) {
      throw ServerException(message: jsonDecode(response.body)['detail']);
    }
  }
}