// lib/feature/asset_managment/domain/entities/asset_history_entity.dart

import 'package:assetsrfid/feature/asset_managment/data/models/asset_history_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // برای IconData, Color

class AssetHistoryEntity extends Equatable {
  final int id;
  final int assetId;
  final String? location;
  final DateTime timestamp;
  final String status; // نمایش رشته‌ای از Enum وضعیت دارایی
  final String eventType; // نمایش رشته‌ای از Enum نوع رویداد
  final int? userId;
  final String? details;
  // اگر نیاز به نمایش نام کاربری دارید: final String? username;

  const AssetHistoryEntity({
    required this.id,
    required this.assetId,
    this.location,
    required this.timestamp,
    required this.status,
    required this.eventType,
    this.userId,
    this.details,
  });

  @override
  List<Object?> get props => [id, assetId, location, timestamp, status, eventType, userId, details];

  factory AssetHistoryEntity.fromResponse(AssetHistoryModel model) {
    return AssetHistoryEntity(
      id: model.id,
      assetId: model.assetId,
      location: model.location,
      timestamp: model.timestamp,
      status: model.status,
      eventType: model.eventType,
      userId: model.userId,
      details: model.details,
    );
  }

  // متد کمکی برای دریافت آیکون بر اساس eventType
  IconData get eventIcon {
    switch (eventType.toLowerCase()) {
      case 'scanned': return Icons.qr_code_scanner_rounded;
      case 'moved': return Icons.swap_horiz_rounded;
      case 'assigned': return Icons.person_outline;
      case 'registered': return Icons.add_circle_outline;
      case 'loaned': return Icons.outbox_outlined;
      case 'returned': return Icons.inbox_outlined;
      default: return Icons.info_outline;
    }
  }

  // متد کمکی برای دریافت رنگ بر اساس eventType/status
  Color get eventColor {
    switch (eventType.toLowerCase()) {
      case 'scanned': return Colors.blue.shade400;
      case 'moved': return Colors.purple.shade400;
      case 'assigned': return Colors.orange.shade400;
      case 'registered': return Colors.green.shade400;
      case 'loaned': return Colors.blueGrey.shade400;
      case 'returned': return Colors.green.shade600;
      default: return Colors.grey;
    }
  }
}