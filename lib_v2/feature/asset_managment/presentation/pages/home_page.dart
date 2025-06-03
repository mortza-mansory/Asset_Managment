import 'package:assetsrfid/feature/asset_managment/presentation/pages/components/Alert.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';

class OverviewCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const OverviewCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

const List<OverviewCardData> _overviewCardDataListLight = [
  OverviewCardData(
      title: 'کل دارایی‌ها',
      value: '10,245',
      icon: Icons.inventory_2_outlined,
      color: Color(0xFF42A5F5)),
  OverviewCardData(
      title: 'فعال',
      value: '9,876',
      icon: Icons.check_circle_outline,
      color: Color(0xFF66BB6A)),
  OverviewCardData(
      title: 'مفقود',
      value: '112',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFEF5350)),
];

const List<OverviewCardData> _overviewCardDataListDark = [
  OverviewCardData(
      title: 'کل دارایی‌ها',
      value: '10,245',
      icon: Icons.inventory_2_outlined,
      color: Color(0xFF90CAF9)),
  OverviewCardData(
      title: 'فعال',
      value: '9,876',
      icon: Icons.check_circle_outline,
      color: Color(0xFFA5D6A7)),
  OverviewCardData(
      title: 'مفقود',
      value: '112',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFEF9A9A)),
];

class _OverviewCard extends StatelessWidget {
  final OverviewCardData data;
  final int index;
  final bool isDarkMode;

  const _OverviewCard({
    required this.data,
    required this.index,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final cardBackgroundColor = isDarkMode
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.12);

    final textColor = isDarkMode ? Colors.white.withOpacity(0.87) : Colors.white;

    final subTextColor = isDarkMode ? Colors.white.withOpacity(0.60) : Colors.white70;

    return Container(
      width: 28.w,
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 1.w),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, color: data.color, size: 7.w),
          SizedBox(height: 1.h),
          Text(
            data.value,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: subTextColor,
            ),
          ),
        ],
      ),
    ).animate().scale(
        duration: 450.ms, delay: (100 * index).ms, curve: Curves.fastOutSlowIn);
  }
}

class ActionButtonData {
  final IconData icon;
  final String label;
  final Color colorLight;
  final Color colorDark;
  final VoidCallback onTap;
  final bool Function()? isLoading;

  const ActionButtonData({
    required this.icon,
    required this.label,
    required this.colorLight,
    required this.colorDark,
    required this.onTap,
    this.isLoading,
  });
}

class _ActionButton extends StatelessWidget {
  final ActionButtonData data;
  final int index;
  final bool isDarkMode;

  const _ActionButton({
    required this.data,
    required this.index,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final bool loading = data.isLoading?.call() ?? false;

    final buttonColor = isDarkMode ? data.colorDark : data.colorLight;

    return Expanded(
      child: GestureDetector(
        onTap: loading ? null : data.onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: loading ? buttonColor.withOpacity(0.7) : buttonColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withOpacity(0.25),
                blurRadius: 6.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                )
              else
                Icon(data.icon, color: Colors.white, size: 7.w),
              SizedBox(height: 1.h),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(
          duration: 450.ms,
          delay: (100 * index).ms,
          curve: Curves.elasticInOut),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  bool _isScanning = false;
  late final List<ActionButtonData> _actionButtonDataList;

  final List<Alert> _allAlerts = [
    Alert(
        id: '1',
        assetName: 'هارد اکسترنال ۱',
        issue: 'مفقود شده',
        severityColorLight: Colors.red,
        severityColorDark: const Color(0xFFEF9A9A),
        isCritical: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    Alert(
        id: '2',
        assetName: 'دریل بوش ۲',
        issue: 'خارج از محدوده',
        severityColorLight: Colors.orange,
        severityColorDark: const Color(0xFFFFCC80),
        isCritical: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1))),
    Alert(
        id: '3',
        assetName: 'لپ‌تاپ دل ۳',
        issue: 'نیاز به تعمیر',
        severityColorLight: const Color(0xFFFFEB3B),
        severityColorDark: const Color(0xFFFFF59D),
        timestamp: DateTime.now().subtract(const Duration(days: 3))),
  ];

  @override
  void initState() {
    super.initState();

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _actionButtonDataList = [
      ActionButtonData(
        icon: Icons.nfc_rounded,
        label: 'اسکن RFID',
        colorLight: const Color(0xFF37474F),
        colorDark: const Color(0xFF546E7A),
        onTap: _startScanAnimation,
        isLoading: () => _isScanning,
      ),
      ActionButtonData(
        icon: Icons.assessment_outlined,
        label: 'گزارش‌گیری',
        colorLight: const Color(0xFF66BB6A),
        colorDark: const Color(0xFF4CAF50),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('در حال تولید گزارش...')),
          );
        },
      ),
      ActionButtonData(
        icon: Icons.swap_horiz_rounded,
        label: 'گردش کار',
        colorLight: const Color(0xFFFFA726),
        colorDark: const Color(0xFFFB8C00),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('نمایش گردش کار...')),
          );
        },
      ),
    ];
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  void _startScanAnimation() {
    if (_isScanning) return;

    setState(() => _isScanning = true);

    _scanAnimationController.forward().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() => _isScanning = false);
          _scanAnimationController.reverse();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اسکن RFID با موفقیت انجام شد!')),
          );
        }
      });
    });
  }

  void _navigateToAlertDetails(Alert alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('نمایش جزئیات برای: ${alert.assetName}')),
    );
  }

  void _navigateToAllAlertsPage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('رفتن به صفحه همه هشدارها...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    List<Alert> sortedAlerts = List.from(_allAlerts);

    sortedAlerts.sort((a, b) {
      if (a.isCritical && !b.isCritical) return -1;
      if (!a.isCritical && b.isCritical) return 1;
      return b.timestamp.compareTo(a.timestamp);
    });

    final List<Alert> topAlerts = sortedAlerts.take(3).toList();

    final scaffoldBackgroundColor = isDarkMode
        ? Colors.white12.withOpacity(0.15)
        : Colors.white;

    final headerGradientColors = isDarkMode
        ? [const Color(0xFF232325), const Color(0xFF2D2D2F)]
        : [const Color(0xFF263238), const Color(0xFF455A64)];

    final headerTextColor = Colors.white;

    final sectionTitleColor = isDarkMode
        ? Colors.white.withOpacity(0.9)
        : Colors.black.withOpacity(0.9);

    final seeAllButtonColor = isDarkMode
        ? const Color(0xFFBB86FC)
        : (Theme.of(context).primaryColor ?? Colors.blue);

    final emptyStateIconColor = isDarkMode ? Colors.green.shade300 : Colors.green.shade600;

    final emptyStateTextColor = isDarkMode
        ? Colors.white.withOpacity(0.75)
        : Colors.black.withOpacity(0.75);

    final emptyStateCardBackground = isDarkMode
        ? const Color(0xFF2C2C2E).withOpacity(0.8)
        : Colors.grey.shade100;

    final currentOverviewDataList =
    isDarkMode ? _overviewCardDataListDark : _overviewCardDataListLight;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: headerGradientColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'مدیریت هوشمند دارایی‌ها',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: headerTextColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isDarkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            color: headerTextColor,
                          ),
                          onPressed: () {
                            context.read<ThemeBloc>().toggleTheme();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'خلاصه وضعیت دارایی‌ها',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: headerTextColor.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(currentOverviewDataList.length, (index) {
                        return _OverviewCard(
                          data: currentOverviewDataList[index],
                          index: index,
                          isDarkMode: isDarkMode,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عملیات سریع',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: sectionTitleColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_actionButtonDataList.length, (index) {
                        return _ActionButton(
                          data: _actionButtonDataList[index],
                          index: index,
                          isDarkMode: isDarkMode,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'آخرین فعالیت‌ها',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: sectionTitleColor,
                      ),
                    ),
                    if (_allAlerts.length > topAlerts.length && topAlerts.isNotEmpty)
                      TextButton(
                        onPressed: _navigateToAllAlertsPage,
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'مشاهده همه (${_allAlerts.length})',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: seeAllButtonColor,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 12.sp, color: seeAllButtonColor),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (topAlerts.isEmpty)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: emptyStateCardBackground,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: emptyStateIconColor, size: 12.w),
                      SizedBox(height: 1.h),
                      Text(
                        'هیچ هشدار مهمی برای نمایش وجود ندارد.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: emptyStateTextColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = topAlerts[index];
                    return AlertItemCard(
                      alert: alert,
                      onTap: () => _navigateToAlertDetails(alert),
                      index: index,
                      isDarkMode: isDarkMode,
                    );
                  },
                ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}