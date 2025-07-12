// lib/feature/asset_managment/data/datasource/asset_remote_datasource.dart

import 'dart:convert';
import 'dart:io';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_category_model.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_history_entity.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_model.dart';
import 'package:http/http.dart' as http;
import 'package:assetsrfid/core/constants/api_constatns.dart';
import 'package:assetsrfid/core/error/exceptions.dart';
import 'package:assetsrfid/feature/auth/utils/token_storage.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

abstract class AssetRemoteDataSource {
  Future<List<AssetModel>> getAssets({
    required int companyId,
    int page = 1,
    int perPage = 20,
    String? searchQuery,
    int? categoryId,
  });

  Future<List<AssetCategoryModel>> getAssetCategories({required int companyId});

  Future<AssetCategoryModel> createAssetCategory({
    required int companyId,
    required String name,
    required int code,
    String? description,
    String? iconName,
    String? colorHex,
  });

  Future<AssetCategoryModel> updateAssetCategory({
    required int categoryId,
    required int companyId,
    String? name,
    int? code,
    String? description,
    String? iconName,
    String? colorHex,
  });

  Future<void> deleteAssetCategory({
    required int categoryId,
    required int companyId,
  });

  Future<AssetModel> updateAsset(int assetId, Map<String, dynamic> updateData);

  Future<AssetModel> getAssetByRfid(String rfidTag);
  Future<List<AssetHistoryModel>> getAssetHistory(int assetId);

  Future<AssetModel> getAssetById(int assetId);

  Future<String> downloadExcelTemplate(String language);
  Future<Map<String, dynamic>> uploadExcelFile(PlatformFile file);
}

class AssetRemoteDataSourceImpl implements AssetRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  AssetRemoteDataSourceImpl({required this.client, required this.tokenStorage});

  @override
  Future<List<AssetModel>> getAssets({
    required int companyId,
    int page = 1,
    int perPage = 20,
    String? searchQuery,
    int? categoryId,
  }) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final Map<String, String> queryParams = {
      'company_id': companyId.toString(),
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search_query'] = searchQuery;
    }
    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }

    final uri =
    Uri.parse('${ApiConstants.baseUrl}/assets/').replace(queryParameters: queryParams);

    final response = await client.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => AssetModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw ServerException(
          message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
    } else if (response.statusCode == 403) {
      throw ServerException(
          message: 'Forbidden. You do not have permission.', statusCode: response.statusCode);
    } else {
      final errorDetail =
          json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Failed to load assets';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    }
  }

  @override
  Future<List<AssetCategoryModel>> getAssetCategories({required int companyId}) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final uri = Uri.parse('${ApiConstants.baseUrl}/assets/categories/');

    final response = await client.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => AssetCategoryModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw ServerException(
          message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
    } else {
      final errorDetail =
          json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Failed to load categories';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    }
  }

  @override
  Future<AssetCategoryModel> createAssetCategory({
    required int companyId,
    required String name,
    required int code,
    String? description,
    String? iconName,
    String? colorHex,
  }) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final uri = Uri.parse('${ApiConstants.baseUrl}/assets/categories');
    final response = await client.post(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'company_id': companyId,
        'name': name,
        'code': code,
        if (description != null) 'description': description,
        if (iconName != null) 'icon_name': iconName,
        if (colorHex != null) 'color_hex': colorHex,
      }),
    );

    if (response.statusCode == 201) {
      return AssetCategoryModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 401) {
      throw ServerException(
          message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
    } else if (response.statusCode == 403) {
      throw ServerException(
          message: 'Forbidden. You do not have permission.', statusCode: response.statusCode);
    } else if (response.statusCode == 409) {
      final errorDetail =
          json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Category already exists.';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    } else {
      final errorDetail =
          json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Failed to create category';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    }
  }

  @override
  Future<AssetCategoryModel> updateAssetCategory({
    required int categoryId,
    required int companyId,
    String? name,
    int? code,
    String? description,
    String? iconName,
    String? colorHex,
  }) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final uri = Uri.parse('${ApiConstants.baseUrl}/assets/categories/$categoryId');
    final response = await client.put(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        if (name != null) 'name': name,
        if (code != null) 'code': code,
        if (description != null) 'description': description,
        if (iconName != null) 'icon_name': iconName,
        if (colorHex != null) 'color_hex': colorHex,
      }),
    );

    if (response.statusCode == 200) {
      return AssetCategoryModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 401) {
      throw ServerException(
          message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
    } else if (response.statusCode == 403) {
      throw ServerException(
          message: 'Forbidden. You do not have permission.', statusCode: response.statusCode);
    } else if (response.statusCode == 404) {
      throw ServerException(message: 'Category not found.', statusCode: response.statusCode);
    } else if (response.statusCode == 409) {
      final errorDetail = json.decode(utf8.decode(response.bodyBytes))['detail'] ??
          'Category name/code already exists.';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    } else {
      final errorDetail =
          json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Failed to update category';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    }
  }

  @override
  Future<void> deleteAssetCategory({required int categoryId, required int companyId}) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final uri = Uri.parse('${ApiConstants.baseUrl}/assets/categories/$categoryId');
    final response = await client.delete(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      throw ServerException(
          message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
    } else if (response.statusCode == 403) {
      throw ServerException(
          message: 'Forbidden. You do not have permission.', statusCode: response.statusCode);
    } else if (response.statusCode == 404) {
      throw ServerException(message: 'Category not found.', statusCode: response.statusCode);
    } else if (response.statusCode == 409) {
      final errorDetail = json.decode(utf8.decode(response.bodyBytes))['detail'] ??
          'Cannot delete category: Assets are linked to it.';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    } else {
      final errorDetail =
          json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Failed to delete category';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    }
  }

  @override
  Future<AssetModel> updateAsset(int assetId, Map<String, dynamic> updateData) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final uri = Uri.parse('${ApiConstants.baseUrl}/assets/$assetId');
    final response = await client.patch(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return AssetModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      throw ServerException(
          message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
    } else if (response.statusCode == 403) {
      throw ServerException(
          message: 'Forbidden. You do not have permission.', statusCode: response.statusCode);
    } else if (response.statusCode == 404) {
      throw ServerException(message: 'Asset not found.', statusCode: response.statusCode);
    } else {
      final errorDetail =
          json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Failed to update asset';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    }
  }

  @override
  Future<AssetModel> getAssetByRfid(String rfidTag) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final uri = Uri.parse('${ApiConstants.baseUrl}/assets/rfid/$rfidTag');
    final response = await client.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return AssetModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      throw ServerException(
          message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
    } else if (response.statusCode == 403) {
      throw ServerException(
          message: 'Forbidden. You do not have permission.', statusCode: response.statusCode);
    } else if (response.statusCode == 404) {
      throw ServerException(
          message: 'Asset with RFID tag $rfidTag not found.', statusCode: response.statusCode);
    } else {
      final errorDetail =
          json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Failed to get asset by RFID';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    }
  }

  @override
  Future<List<AssetHistoryModel>> getAssetHistory(int assetId) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final uri = Uri.parse('${ApiConstants.baseUrl}/assets/$assetId/history');
    final response = await client.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => AssetHistoryModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw ServerException(
          message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
    } else if (response.statusCode == 403) {
      throw ServerException(
          message: 'Forbidden. You do not have permission.', statusCode: response.statusCode);
    } else if (response.statusCode == 404) {
      throw ServerException(
          message: 'Asset history for asset ID $assetId not found.', statusCode: response.statusCode);
    } else {
      final errorDetail = json.decode(utf8.decode(response.bodyBytes))['detail'] ??
          'Failed to get asset history';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    }
  }

  @override
  Future<AssetModel> getAssetById(int assetId) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final uri = Uri.parse('${ApiConstants.baseUrl}/assets/$assetId');
    final response = await client.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return AssetModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      throw ServerException(
          message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
    } else if (response.statusCode == 403) {
      throw ServerException(
          message: 'Forbidden. You do not have permission.', statusCode: response.statusCode);
    } else if (response.statusCode == 404) {
      throw ServerException(message: 'Asset with ID $assetId not found.', statusCode: response.statusCode);
    } else {
      final errorDetail =
          json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Failed to get asset by ID';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    }
  }

  @override
  Future<String> downloadExcelTemplate(String language) async {
    final token = tokenStorage.getAccessToken();
    print('DEBUG: Token retrieved for download: $token'); // Debug print
    if (token == null) throw ServerException(message: 'Not authenticated');

    final String endpoint =
        '${ApiConstants.baseUrl}/assets/download_excel_template/$language';
    print('DEBUG: Download endpoint: $endpoint'); // Debug print
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'asset_template_$language.xlsx';
    final filePath = '${directory.path}/$fileName';

    try { // Added try-catch for network request itself
      final response = await client.get(
        Uri.parse(endpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('DEBUG: Download response status code: ${response.statusCode}'); // Debug print
      print('DEBUG: Download response body: ${response.body}'); // Debug print


      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else if (response.statusCode == 401) {
        throw ServerException(
            message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        final errorDetail =
            json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Failed to download template.';
        throw ServerException(message: errorDetail, statusCode: response.statusCode);
      } else {
        throw ServerException(
            message: 'Failed to download template: Status Code ${response.statusCode}',
            statusCode: response.statusCode);
      }
    } catch (e) {
      print('DEBUG: Exception during download: $e'); // Catch any other exceptions
      throw ServerException(message: 'Network or unexpected error during download: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> uploadExcelFile(PlatformFile file) async {
    final token = tokenStorage.getAccessToken();
    if (token == null) throw ServerException(message: 'Not authenticated');

    final String endpoint = '${ApiConstants.baseUrl}/assets/upload_excel/';
    var request = http.MultipartRequest('POST', Uri.parse(endpoint));
    request.headers['Authorization'] = 'Bearer $token';

    if (file.path == null) {
      throw ClientException('File path is null.');
    }

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path!,
      filename: file.name,
    ));

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 401) {
      throw ServerException(
          message: 'Unauthorized. Please log in again.', statusCode: response.statusCode);
    } else if (response.statusCode == 403 || response.statusCode == 400) {
      final errorDetail =
          json.decode(utf8.decode(response.bodyBytes))['detail'] ?? 'Failed to upload file.';
      throw ServerException(message: errorDetail, statusCode: response.statusCode);
    } else {
      throw ServerException(
          message: 'Failed to upload file: Status Code ${response.statusCode}',
          statusCode: response.statusCode);
    }
  }
}