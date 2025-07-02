import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/pages/components/Alert.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentActivityPage extends StatefulWidget {
  const RecentActivityPage({super.key});

  @override
  State<RecentActivityPage> createState() => _RecentActivityPageState();
}

class _RecentActivityPageState extends State<RecentActivityPage> {
  late List<Alert> _activities;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Leave this empty for context-dependent init
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _activities = _getMockAlerts();
      _isInitialized = true;
    }
  }

  List<Alert> _getMockAlerts() {
    final l10n = context.l10n;
    return [
      Alert(id: '1', assetName: 'هارد اکسترنال ۱', issue: l10n.alertIssueMissing, severityColorLight: Colors.red, severityColorDark: const Color(0xFFEF9A9A), isCritical: true, timestamp: DateTime.now().subtract(const Duration(hours: 2))),
      Alert(id: '2', assetName: 'دریل بوش ۲', issue: l10n.alertIssueOutOfRange, severityColorLight: Colors.orange, severityColorDark: const Color(0xFFFFCC80), isCritical: true, timestamp: DateTime.now().subtract(const Duration(days: 1))),
      Alert(id: '3', assetName: 'لپ‌تاپ دل ۳', issue: l10n.alertIssueNeedsRepair, severityColorLight: const Color(0xFFFFEB3B), severityColorDark: const Color(0xFFFFF59D), timestamp: DateTime.now().subtract(const Duration(days: 3))),
      Alert(id: '4', assetName: 'پروژکتور Epson', issue: l10n.alertIssueNeedsRepair, severityColorLight: const Color(0xFFFFEB3B), severityColorDark: const Color(0xFFFFF59D), timestamp: DateTime.now().subtract(const Duration(days: 5))),
      Alert(id: '5', assetName: 'سرور HP G8', issue: l10n.alertIssueMissing, severityColorLight: Colors.red, severityColorDark: const Color(0xFFEF9A9A), isCritical: true, timestamp: DateTime.now().subtract(const Duration(days: 6))),
    ];
  }

  Future<void> _refreshActivities() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _activities = _getMockAlerts()..shuffle();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1E1E20) : const Color(0xFFF4F6F8);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: l10n.filterButtonTooltip,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.refreshButtonTooltip,
            onPressed: _refreshActivities,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshActivities,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _activities.length,
          itemBuilder: (context, index) {
            final alert = _activities[index];
            return AlertItemCard(
              alert: alert,
              onTap: () {},
              index: index,
              isDarkMode: isDarkMode,
            ).animate().fadeIn(delay: (100 * (index % 10)).ms).slideX(begin: 0.1, duration: 300.ms);
          },
        ),
      ),
    );
  }
}
