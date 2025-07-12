import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_history/asset_history_bloc.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_history/asset_history_event.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_history/asset_history_state.dart';

import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_history_entity.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart'; // برای AssetEventType و AssetStatus


class AssetHistoryPage extends StatefulWidget {
  final int assetId;

  const AssetHistoryPage({super.key, required this.assetId}); // assetId را در constructor اجباری می‌کنیم

  @override
  State<AssetHistoryPage> createState() => _AssetHistoryPageState();
}

class _AssetHistoryPageState extends State<AssetHistoryPage> {



  @override
  void initState() {
    super.initState();
    context.read<AssetHistoryBloc>().add(LoadAssetHistoryEvent(assetId: widget.assetId));
  }



  void _filterEvents(AssetEventType? filter) {
    context.read<AssetHistoryBloc>().add(FilterAssetHistory(filterType: filter));
  }

  String _localizedEventType(String eventType, AppLocalizations l10n) {
    switch(eventType.toLowerCase()) {
      case 'scanned': return l10n.assetEventTypeScanned;
      case 'moved': return l10n.assetEventTypeMoved;
      case 'assigned': return l10n.assetEventTypeAssigned;
      case 'registered': return l10n.assetEventTypeRegistered;
      case 'loaned': return l10n.assetEventTypeLoaned;
      case 'returned': return l10n.assetEventTypeReturned;
      default: return eventType;
    }
  }
  // تابع کمکی برای ترجمه وضعیت دارایی از enum AssetStatus
  String _localizedAssetStatus(AssetStatus status, AppLocalizations l10n) {
    switch (status) {
      case AssetStatus.active: return l10n.assetStatusActive;
      case AssetStatus.inactive: return l10n.assetStatusInactive;
      case AssetStatus.maintenance: return l10n.assetStatusMaintenance;
      case AssetStatus.disposed: return l10n.assetStatusDisposed;
      case AssetStatus.on_loan: return l10n.assetStatusOnLoan;
      default: return status.name;
    }
  }
  // Helper to get status color based on AssetStatus enum
  Color _getStatusColor(AssetStatus status) {
    switch (status) {
      case AssetStatus.active:
        return Colors.green.shade400;
      case AssetStatus.inactive:
        return Colors.red.shade400;
      case AssetStatus.maintenance:
        return Colors.orange.shade400;
      case AssetStatus.disposed:
        return Colors.grey;
      case AssetStatus.on_loan:
        return Colors.blue.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor =
    isDarkMode ? const Color(0xFF1E1E20) : const Color(0xFFF4F6F8);
    final primaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.statusHistoryTitle, style: GoogleFonts.poppins(color: primaryTextColor)),
      ),
      body: BlocConsumer<AssetHistoryBloc, AssetHistoryState>(
        listener: (context, state) {
          if (state is AssetHistoryError) {
            context.showErrorDialog(state.message);
          }
        },
        builder: (context, state) {
          if (state is AssetHistoryLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade600),
              ),
            );
          } else if (state is AssetHistoryLoaded) {
            final asset = state.asset;
            final filteredEvents = state.filteredHistory;
            final selectedFilter = state.currentFilter;

            return Column(
              children: [
                _buildAssetSummaryHeader(context, asset), // هدر با اطلاعات واقعی دارایی
                _buildFilterChips(context, selectedFilter), // فیلترها
                Expanded(
                  child: filteredEvents.isEmpty
                      ? Center(
                      child: Text(l10n.historyNoEventsFound, // متن وقتی هیچ رویدادی پیدا نشد
                          style: GoogleFonts.poppins(color: primaryTextColor.withOpacity(0.7))))
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      return _HistoryTimelineTile(
                        event: filteredEvents[index],
                        isFirst: index == 0,
                        isLast: index == filteredEvents.length - 1,
                        localizedEventType: (type) => _localizedEventType(type, l10n), // پاس دادن تابع ترجمه
                      ).animate().fadeIn(delay: (100 * index).ms).slideX(
                          begin: 0.2, duration: 400.ms, curve: Curves.easeOut);
                    },
                  ),
                ),
              ],
            );
          } else if (state is AssetHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 20.w, color: Colors.red.shade400),
                  SizedBox(height: 2.h),
                  Text(state.message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red.shade400)),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () => context.read<AssetHistoryBloc>().add(LoadAssetHistoryEvent(assetId: widget.assetId)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: Text(l10n.tryAgain, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink(); // حالت پیش‌فرض
        },
      ),
    );
  }

  // Header Summary: نمایش خلاصه دارایی (نام و ID)
  Widget _buildAssetSummaryHeader(BuildContext context, AssetEntity asset) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      margin: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
              blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          // IconAssetCategory یا یک آیکون پیش‌فرض (مانند آنچه در AssetDetailPage داریم)
          Icon(Icons.laptop_mac_outlined, color: _getStatusColor(asset.status), size: 28),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(asset.name,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 13.sp, color: textColor)),
              Text(asset.assetId,
                  style: GoogleFonts.poppins(color: textColor, fontSize: 11.sp)),
            ],
          ),
        ],
      ),
    );
  }

  // Filter Chips: فیلتر کردن رویدادها بر اساس نوع
  Widget _buildFilterChips(BuildContext context, AssetEventType? selectedFilter) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final filterChipBackgroundColor = isDarkMode ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
    final filterChipSelectedColor = isDarkMode ? Colors.teal.shade700 : Colors.teal.shade400;
    final filterChipTextColor = isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black87;
    final filterChipSelectedTextColor = Colors.white;

    final Map<String, AssetEventType?> filters = {
      l10n.historyFilterAll: null,
      l10n.historyFilterScan: AssetEventType.scanned, // از AssetEventType استفاده می‌کنیم
      l10n.historyFilterCustodianChange: AssetEventType.assigned, // یا moved، بسته به بک‌اند
      l10n.historyFilterStatusChange: AssetEventType.registered, // یا statusChanged اگر داشتید
      l10n.historyFilterMaintenance: AssetEventType.moved, // یا maintenance اگر داشتید
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.entries.map((entry) {
            final isSelected = selectedFilter == entry.value;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: FilterChip(
                label: Text(entry.key),
                selected: isSelected,
                onSelected: (selected) {
                  _filterEvents(isSelected ? null : entry.value);
                },
                selectedColor: filterChipSelectedColor,
                checkmarkColor: filterChipSelectedTextColor,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: isSelected ? filterChipSelectedTextColor : filterChipTextColor,
                ),
                backgroundColor: filterChipBackgroundColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// _HistoryTimelineTile: ویجت نمایش یک آیتم در تایم‌لاین تاریخچه
class _HistoryTimelineTile extends StatelessWidget {
  final AssetHistoryEntity event; // اکنون از AssetHistoryEntity استفاده می‌کند
  final bool isFirst;
  final bool isLast;
  final Function(String eventType) localizedEventType; // برای ترجمه نوع رویداد

  const _HistoryTimelineTile({
    required this.event,
    this.isFirst = false,
    this.isLast = false,
    required this.localizedEventType, // باید پاس داده شود
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final primaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;
    final lineColor = Colors.grey.shade700;

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              if (!isFirst)
                Expanded(child: Container(width: 2, color: lineColor)),
              CircleAvatar(
                  radius: 2.2.w,
                  backgroundColor: event.eventColor, // از Entity می‌آید
                  child: Icon(event.eventIcon, size: 3.w, color: Colors.white)), // از Entity می‌آید
              if (!isLast)
                Expanded(child: Container(width: 2, color: lineColor)),
            ],
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 3.h, top: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${localizedEventType(event.eventType)}: ${event.location ?? 'N/A'}', // از تابع پاس داده شده استفاده می‌کند
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor),
                  ),
                  if (event.details != null) // اگر جزئیات وجود دارد
                    Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: Text(
                        event.details!,
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp, color: secondaryTextColor),
                      ),
                    ),
                  SizedBox(height: 0.8.h),
                  Text(
                    DateFormat('yyyy/MM/dd – HH:mm').format(event.timestamp),
                    style: GoogleFonts.poppins(
                        fontSize: 9.sp, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}