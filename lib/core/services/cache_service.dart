// lib/core/services/cache_service.dart

import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class CacheService {
  final _box = GetStorage();

  static String _getAssetCategoriesCacheKey(int companyId) {
    return 'asset_categories_cache_company_${companyId}';
  }

  static String _getAssetsCacheKey(int companyId, String? searchQuery, int? categoryId, int page, int perPage) {
    return 'assets_cache_company_${companyId}_query_${searchQuery ?? ''}_category_${categoryId ?? ''}_page_${page}_perPage_${perPage}';
  }

  static const Duration _categoriesCacheExpiry = Duration(minutes: 5);
  static const Duration _assetsCacheExpiry = Duration(seconds: 30);


  Future<void> saveCategories(List<Map<String, dynamic>> categoriesJson, {required int companyId}) async {
    final cacheKey = _getAssetCategoriesCacheKey(companyId);
    final cacheData = {
      'data': categoriesJson,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _box.write(cacheKey, jsonEncode(cacheData));
  }

  List<Map<String, dynamic>>? getCategories({required int companyId}) {
    final cacheKey = _getAssetCategoriesCacheKey(companyId);
    final cachedString = _box.read<String>(cacheKey);
    if (cachedString == null) return null;

    final cachedData = jsonDecode(cachedString);
    final timestamp = DateTime.parse(cachedData['timestamp']);

    if (DateTime.now().difference(timestamp) > _categoriesCacheExpiry) {
      _box.remove(cacheKey); // Cache expired
      return null;
    }
    return List<Map<String, dynamic>>.from(cachedData['data']);
  }

  Future<void> saveAssets(int companyId, String? searchQuery, int? categoryId, int page, int perPage, List<Map<String, dynamic>> assetsJson) async {
    final cacheKey = _getAssetsCacheKey(companyId, searchQuery, categoryId, page, perPage);
    final cacheData = {
      'data': assetsJson,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _box.write(cacheKey, jsonEncode(cacheData));
  }

  List<Map<String, dynamic>>? getAssets(int companyId, String? searchQuery, int? categoryId, int page, int perPage) {
    final cacheKey = _getAssetsCacheKey(companyId, searchQuery, categoryId, page, perPage);
    final cachedString = _box.read<String>(cacheKey);
    if (cachedString == null) return null;

    final cachedData = jsonDecode(cachedString);
    final timestamp = DateTime.parse(cachedData['timestamp']);

    if (DateTime.now().difference(timestamp) > _assetsCacheExpiry) {
      _box.remove(cacheKey); // Cache expired
      return null;
    }
    return List<Map<String, dynamic>>.from(cachedData['data']);
  }

  // جدید: متد برای پاک کردن کش دسته‌بندی‌های یک شرکت خاص
  Future<void> clearCategoriesCacheForCompany(int companyId) async {
    final cacheKey = _getAssetCategoriesCacheKey(companyId);
    await _box.remove(cacheKey);
  }

// اگر نیاز به پاک کردن کش دارایی‌ها به صورت عمومی‌تر (نه فقط بر اساس کوئری خاص) دارید،
// باید کلیدهای بیشتری را ردیابی کنید یا از clearAllCache() استفاده کنید.
// فعلاً، بر روی expire شدن کش دارایی‌ها تکیه می‌کنیم.
// Future<void> clearAllCache() async {
//   await _box.erase();
// }
}