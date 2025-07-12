// lib/feature/asset_managment/data/models/asset_history_model.dart

import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_history_entity.dart';

class AssetHistoryModel {
  final int id;
  final int assetId;
  final String? location;
  final DateTime timestamp;
  final String status; // رشته‌ای
  final String eventType; // رشته‌ای
  final int? userId;
  final String? details;
  // اگر در Response بک‌اند نام کاربری نیز وجود دارد: final String? userUsername;

  AssetHistoryModel({
    required this.id,
    required this.assetId,
    this.location,
    required this.timestamp,
    required this.status,
    required this.eventType,
    this.userId,
    this.details,
    // this.userUsername,
  });

  factory AssetHistoryModel.fromJson(Map<String, dynamic> json) {
    return AssetHistoryModel(
      id: json['id'] as int,
      assetId: json['asset_id'] as int,
      location: json['location'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      eventType: json['event_type'] as String,
      userId: json['user_id'] as int?,
      details: json['details'] as String?,
      // userUsername: json['user_username'] as String?,
    );
  }

// در حال حاضر متد toJson نیازی نیست، چون فقط داده دریافت می‌کنیم.
}