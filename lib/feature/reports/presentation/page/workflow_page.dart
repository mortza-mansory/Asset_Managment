import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:intl/intl.dart';

enum WorkflowActionType { added, edited, transferred, statusChanged, offlineScan }

class WorkflowEvent {
  final String adminName;
  final String assetName;
  final WorkflowActionType actionType;
  final String? details;
  final DateTime timestamp;
  final bool isOffline;
  final bool isActionable;

  WorkflowEvent({
    required this.adminName,
    required this.assetName,
    required this.actionType,
    required this.timestamp,
    this.details,
    this.isOffline = false,
    this.isActionable = false,
  });
}

class WorkflowPage extends StatefulWidget {
  const WorkflowPage({super.key});

  @override
  State<WorkflowPage> createState() => _WorkflowPageState();
}

class _WorkflowPageState extends State<WorkflowPage> {
  late List<WorkflowEvent> _allEvents;
  late List<WorkflowEvent> _filteredEvents;
  WorkflowActionType? _selectedFilter;
  DateTimeRange? _selectedDateRange;

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
      WorkflowEvent(adminName: 'آفلاین', assetName: 'گاوصندوق دیجیتال', actionType: WorkflowActionType.offlineScan, timestamp: DateTime.now().subtract(Duration(minutes: 5)), isOffline: true, isActionable: true),
      WorkflowEvent(adminName: 'علی محمدی', assetName: 'پرینتر HP M404dn', actionType: WorkflowActionType.added, timestamp: DateTime.now().subtract(Duration(minutes: 30))),
      WorkflowEvent(adminName: 'سارا رضایی', assetName: 'لپ‌تاپ Dell XPS 15', actionType: WorkflowActionType.transferred, details: l10n.workflowDetailTo('بخش فنی'), timestamp: DateTime.now().subtract(Duration(hours: 2))),
      WorkflowEvent(adminName: 'مدیر سیستم', assetName: 'دوربین Nikon Z6', actionType: WorkflowActionType.edited, details: 'ویرایش مشخصات فنی', timestamp: DateTime.now().subtract(Duration(hours: 5))),
      WorkflowEvent(adminName: 'سارا رضایی', assetName: 'سرور G5', actionType: WorkflowActionType.statusChanged, details: l10n.workflowDetailToStatus(l10n.assetStatusMissing), timestamp: DateTime.now().subtract(Duration(days: 1))),
      WorkflowEvent(adminName: 'علی محمدی', assetName: 'مانیتور Samsung G7', actionType: WorkflowActionType.transferred, details: l10n.workflowDetailTo('انبار'), timestamp: DateTime.now().subtract(Duration(days: 2))),
    ];
    _applyFilters();
  }

  void _applyFilters() {
    List<WorkflowEvent> tempEvents = List.from(_allEvents);

    if (_selectedFilter != null) {
      tempEvents = tempEvents.where((event) => event.actionType == _selectedFilter).toList();
    }

    if (_selectedDateRange != null) {
      tempEvents = tempEvents.where((event) {
        final eventDate = event.timestamp;
        final startDate = _selectedDateRange!.start;
        final endDate = _selectedDateRange!.end;
        return (eventDate.isAfter(startDate) || eventDate.isAtSameMomentAs(startDate)) &&
            (eventDate.isBefore(endDate.add(const Duration(days: 1))) || eventDate.isAtSameMomentAs(endDate));
      }).toList();
    }

    setState(() {
      _filteredEvents = tempEvents;
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1E1E20) : const Color(0xFFF4F6F8);
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(context),
          _buildDateRangeDisplay(context),
          const Divider(height: 1),
          Expanded(
            child: _filteredEvents.isEmpty
                ? Center(child: Text('هیچ فعالیتی برای این فیلتر یافت نشد.', style: GoogleFonts.poppins()))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) {
                return _WorkflowEventTile(event: _filteredEvents[index])
                    .animate()
                    .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                    .slideX(begin: 0.2, curve: Curves.easeOut);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final l10n = context.l10n;
    final filters = {
      l10n.workflowFilterAll: null,
      l10n.workflowFilterTransfers: WorkflowActionType.transferred,
      l10n.workflowFilterEdits: WorkflowActionType.edited,
      l10n.workflowFilterStatusChanges: WorkflowActionType.statusChanged,
    };

    // Placeholder widget to avoid returning null
    return Wrap(); // Or replace with your actual chip-building logic
  }


  Widget _buildDateRangeDisplay(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
    final primaryColor = Theme.of(context).primaryColor;

    String dateRangeText;
    if (_selectedDateRange == null) {
      dateRangeText = l10n.dateRangeAllTime;
    } else {
      final start = DateFormat('yyyy/MM/dd').format(_selectedDateRange!.start);
      final end = DateFormat('yyyy/MM/dd').format(_selectedDateRange!.end);
      dateRangeText = '$start - $end';
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.dateRangeLabel, style: GoogleFonts.poppins(fontSize: 11.sp, color: secondaryTextColor)),
          TextButton(
            onPressed: _selectDateRange,
            child: Row(
              children: [
                Text(dateRangeText, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor)),
                SizedBox(width: 1.w),
                Icon(Icons.calendar_today_outlined, size: 4.w, color: primaryColor),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _WorkflowEventTile extends StatelessWidget {
  final WorkflowEvent event;
  const _WorkflowEventTile({required this.event});

  Map<String, dynamic> _getUIData(BuildContext context) {
    final l10n = context.l10n;
    switch (event.actionType) {
      case WorkflowActionType.added:
        return {
          'icon': Icons.add_circle_outline,
          'color': Colors.green.shade400,
          'text': l10n.workflowActionAdded(event.adminName)
        };
      case WorkflowActionType.edited:
        return {
          'icon': Icons.edit_outlined,
          'color': Colors.blue.shade400,
          'text': l10n.workflowActionEdited(event.adminName)
        };
      case WorkflowActionType.transferred:
        return {
          'icon': Icons.swap_horiz_rounded,
          'color': Colors.purple.shade400,
          'text': l10n.workflowActionTransferred(event.adminName)
        };
      case WorkflowActionType.statusChanged:
        return {
          'icon': Icons.sync_alt_rounded,
          'color': Colors.orange.shade600,
          'text': l10n.workflowActionChangedStatus(event.adminName)
        };
      case WorkflowActionType.offlineScan:
        return {
          'icon': Icons.wifi_off_rounded,
          'color': Colors.red.shade400,
          'text': l10n.workflowActionOfflineScan(event.adminName)
        };
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;
    final uiData = _getUIData(context);

    return Card(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: uiData['color'].withOpacity(event.isOffline ? 0.8 : 0.5), width: event.isOffline ? 2 : 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: uiData['color'].withOpacity(0.2), child: Icon(uiData['icon'], color: uiData['color'])),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    uiData['text'],
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: secondaryTextColor),
                  ),
                ),
                if(event.isActionable)
                  OutlinedButton.icon(
                    onPressed: (){},
                    icon: Icon(Icons.sync_rounded, size: 4.w),
                    label: Text(context.l10n.syncButton),
                  )
              ],
            ),
            SizedBox(height: 1.5.h),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 11.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.assetName,
                    style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
                  ),
                  if (event.details != null)
                    Text(
                      event.details!,
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: primaryTextColor.withOpacity(0.8)),
                    ),
                  SizedBox(height: 1.h),
                  Text(
                    DateFormat('yyyy/MM/dd – HH:mm').format(event.timestamp),
                    style: GoogleFonts.poppins(fontSize: 9.sp, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


