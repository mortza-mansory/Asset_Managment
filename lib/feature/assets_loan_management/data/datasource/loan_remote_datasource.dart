import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:assetsrfid/core/constants/api_constatns.dart';
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/feature/assets_loan_management/data/models/loan_model.dart';
import 'package:assetsrfid/feature/auth/utils/token_storage.dart';

abstract class LoanRemoteDataSource {
  Future<List<LoanModel>> getMyLoans(int userId, int companyId);
  Future<List<LoanModel>> getLoanedOutAssets(int companyId);
  Future<LoanModel> createLoan(LoanCreationRequestModel request);
  Future<void> returnLoan(int loanId);
  Future<LoanModel> getLoanById(String loanId);

  Future<List<LoanModel>> _listAllLoansFiltered({
    required int companyId,
    int? recipientId,
    bool? isActive,
  });
}

class LoanRemoteDataSourceImpl implements LoanRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  LoanRemoteDataSourceImpl({required this.client, required this.tokenStorage});

  Map<String, String> _getHeaders() {
    final token = tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<LoanModel>> _listAllLoansFiltered({
    required int companyId,
    int? recipientId,
    bool? isActive,
  }) async {
    final Map<String, String> queryParams = {
      'company_id': companyId.toString(),
    };
    if (recipientId != null) {
      queryParams['recipient_id'] = recipientId.toString();
    }
    if (isActive != null) {
      queryParams['is_active'] = isActive.toString();
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/assets/loans/').replace(queryParameters: queryParams);

    final response = await client.get(
      uri,
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => LoanModel.fromJson(json)).toList();
    } else {
      throw ServerException(message: 'Failed to load loans: ${response.statusCode}');
    }
  }

  @override
  Future<List<LoanModel>> getMyLoans(int userId, int companyId) async {
    return _listAllLoansFiltered(
      companyId: companyId,
      recipientId: userId,
      isActive: true,
    );
  }

  @override
  Future<List<LoanModel>> getLoanedOutAssets(int companyId) async {
    return _listAllLoansFiltered(
      companyId: companyId,
      isActive: true,
    );
  }

  @override
  Future<LoanModel> createLoan(LoanCreationRequestModel request) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/assets/loans/'),
      headers: _getHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return LoanModel.fromJson(jsonResponse);
    } else {
      throw ServerException(message: 'Failed to create loan: ${response.statusCode}');
    }
  }

  @override
  Future<void> returnLoan(int loanId) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/assets/loans/$loanId/return'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw ServerException(message: 'Failed to return loan: ${response.statusCode}');
    }
  }

  @override
  Future<LoanModel> getLoanById(String loanId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/assets/loans/$loanId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return LoanModel.fromJson(jsonResponse);
    } else {
      throw ServerException(message: 'Failed to load loan by ID: ${response.statusCode}');
    }
  }
}