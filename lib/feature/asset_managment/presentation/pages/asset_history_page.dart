import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum HistoryEventType { scan, custodianChange, maintenance, statusChange }

class HistoryEvent {
  final String title;
  final String? subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final HistoryEventType type;

  HistoryEvent({
    required this.title,
    this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class AssetHistoryPage extends StatefulWidget {
  const AssetHistoryPage({super.key});

  @override
  State<AssetHistoryPage> createState() => _AssetHistoryPageState();
}

class _AssetHistoryPageState extends State<AssetHistoryPage> {
  late List<HistoryEvent> _allEvents;
  late List<HistoryEvent> _filteredEvents;
  HistoryEventType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _filteredEvents = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeEvents();
  }

  void _initializeEvents() {
    final l10n = context.l10n;
    _allEvents = [
      HistoryEvent(
          title: '${l10n.historyEventScan} انبار مرکزی',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          icon: Icons.qr_code_scanner_rounded,
          color: Colors.blue.shade400,
          type: HistoryEventType.scan),
      HistoryEvent(
          title: '${l10n.historyEventCustodianChange} آقای اکبری',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          icon: Icons.person_outline,
          color: Colors.purple.shade400,
          type: HistoryEventType.custodianChange),
      HistoryEvent(
          title:
          '${l10n.historyEventStatusChange} "${l10n.assetStatusActive}"',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          icon: Icons.check_circle_outline,
          color: Colors.green.shade400,
          type: HistoryEventType.statusChange),
      HistoryEvent(
          title: l10n.historyEventMaintenanceStart,
          subtitle: 'مشکل: صفحه نمایش',
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
          icon: Icons.build_outlined,
          color: Colors.orange.shade600,
          type: HistoryEventType.maintenance),
      HistoryEvent(
          title: '${l10n.historyEventScan} دفتر فنی',
          timestamp: DateTime.now().subtract(const Duration(days: 16)),
          icon: Icons.qr_code_scanner_rounded,
          color: Colors.blue.shade400,
          type: HistoryEventType.scan),
    ];
    _filteredEvents = List.from(_allEvents);
  }

  void _filterEvents(HistoryEventType? filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == null) {
        _filteredEvents = List.from(_allEvents);
      } else {
        _filteredEvents =
            _allEvents.where((event) => event.type == filter).toList();
      }
    });
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
      ),
      body: Column(
        children: [
          _buildAssetSummaryHeader(context),
          _buildFilterChips(context),
          Expanded(
            child: _filteredEvents.isEmpty
                ? Center(
                child: Text('هیچ رویدادی برای این فیلتر یافت نشد.',
                    style: GoogleFonts.poppins()))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) {
                return _HistoryTimelineTile(
                  event: _filteredEvents[index],
                  isFirst: index == 0,
                  isLast: index == _filteredEvents.length - 1,
                ).animate().fadeIn(delay: (100 * index).ms).slideX(
                    begin: 0.2, duration: 400.ms, curve: Curves.easeOut);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetSummaryHeader(BuildContext context) {
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
          const Icon(Icons.laptop_mac_outlined,
              color: Colors.blue, size: 28),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('لپ‌تاپ Dell XPS 15',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 13.sp)),
              Text('LP-00125',
                  style: GoogleFonts.poppins(color: textColor, fontSize: 11.sp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final l10n = context.l10n;
    final filters = {
      l10n.historyFilterAll: null,
      l10n.historyFilterStatus: HistoryEventType.statusChange,
      l10n.historyFilterLocation: HistoryEventType.scan,
      l10n.historyFilterUser: HistoryEventType.custodianChange,
      l10n.historyFilterMaintenance: HistoryEventType.maintenance,
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.entries.map((entry) {
            final isSelected = _selectedFilter == entry.value;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: FilterChip(
                label: Text(entry.key),
                selected: isSelected,
                onSelected: (selected) {
                  _filterEvents(isSelected ? null : entry.value);
                },
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                checkmarkColor: Theme.of(context).primaryColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _HistoryTimelineTile extends StatelessWidget {
  final HistoryEvent event;
  final bool isFirst;
  final bool isLast;

  const _HistoryTimelineTile({
    required this.event,
    this.isFirst = false,
    this.isLast = false,
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
                  backgroundColor: event.color,
                  child: Icon(event.icon, size: 3.w, color: Colors.white)),
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
                    event.title,
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor),
                  ),
                  if (event.subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: Text(
                        event.subtitle!,
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