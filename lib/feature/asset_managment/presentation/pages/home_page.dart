import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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

    final textColor =
        isDarkMode ? Colors.white.withOpacity(0.87) : Colors.white;

    final subTextColor =
        isDarkMode ? Colors.white.withOpacity(0.60) : Colors.white70;

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

class Alert {
  final String id;

  final String assetName;

  final String issue;

  final Color severityColorLight;

  final Color severityColorDark;

  final bool isCritical;

  final DateTime timestamp;

  const Alert({
    required this.id,
    required this.assetName,
    required this.issue,
    required this.severityColorLight,
    required this.severityColorDark,
    this.isCritical = false,
    required this.timestamp,
  });
}

class _AlertItemCard extends StatelessWidget {
  final Alert alert;

  final VoidCallback onTap;

  final int index;

  final bool isDarkMode;

  const _AlertItemCard({
    required this.alert,
    required this.onTap,
    required this.index,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final cardBackgroundColor = isDarkMode
        ? const Color(0xFF2C2C2E)
        : Colors.white;

    final textColor = isDarkMode
        ? Colors.white.withOpacity(0.87)
        : Colors.black.withOpacity(0.87);

    final subTextColor = isDarkMode
        ? Colors.white.withOpacity(0.60)
        : Colors.black.withOpacity(0.60);

    final arrowColor = isDarkMode
        ? Colors.white.withOpacity(0.50)
        : Colors.black.withOpacity(0.50);

    final alertSeverityColor =
        isDarkMode ? alert.severityColorDark : alert.severityColorLight;

    final iconColor =
        isDarkMode ? alert.severityColorDark : alert.severityColorLight;

    IconData alertIconData;

    if (alertSeverityColor ==
        (isDarkMode ? const Color(0xFFEF9A9A) : Colors.red)) {
      alertIconData = Icons.error_outline_rounded;
    } else if (alertSeverityColor ==
        (isDarkMode ? const Color(0xFFFFCC80) : Colors.orange)) {
      alertIconData = Icons.warning_amber_rounded;
    } else if (alertSeverityColor ==
        (isDarkMode ? const Color(0xFFFFF59D) : const Color(0xFFFFEB3B))) {
      alertIconData = Icons.info_outline_rounded;
    } else {
      alertIconData = Icons.notifications_none_rounded;
    }

    return Card(
      color: cardBackgroundColor,

      elevation: isDarkMode ? 1.5 : 2.5, // سایه کمی متفاوت

      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: alertSeverityColor.withOpacity(isDarkMode ? 0.7 : 1.0),
            width: 1.5),
      ), // گوشه‌های گردتر و بوردر

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              Icon(
                alertIconData,
                color: iconColor,
                size: 7.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.assetName,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      alert.issue,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        color: subTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 4.5.w, color: arrowColor),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
        .slideX(begin: 0.1, duration: 300.ms);
  }
}

// -------- MODIFIED: CustomFloatingNavBar --------

class NavItem {
  final IconData icon;

  final String text; // متن برای نمایش

  final String tooltip;

  const NavItem(
      {required this.icon, required this.text, required this.tooltip});
}

class CustomFloatingNavBar extends StatelessWidget {
  final bool isDarkMode;

  final int selectedIndex;

  final Function(int) onItemTapped;

  final List<NavItem> items;

  const CustomFloatingNavBar({
    super.key,
    required this.isDarkMode,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
  });

// مشابه تابع AdaptiveSpace و containerWidth در کد نمونه شما

  double _getExpandedWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

// این مقادیر را می‌توانید بر اساس نیاز تنظیم کنید

// هدف این است که آیتم باز شده فضای بیشتری بگیرد اما نه تمام عرض

    if (screenWidth <= 380)
      return screenWidth * 0.35; // برای صفحه‌های خیلی کوچک

    if (screenWidth <= 450) return screenWidth * 0.32;

    return screenWidth * 0.28; // برای صفحه‌های بزرگتر
  }

  @override
  Widget build(BuildContext context) {
    final navBarBackgroundColor = isDarkMode
        ? const Color(0xFF2C2C2E)
        : Colors.white; // کمی روشن‌تر از پس‌زمینه دارک

    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.06)
        : Colors.grey.withOpacity(0.3);

    final selectedItemColorLight = Colors.grey;

    final selectedItemColorDark =
        const Color(0xFFBB86FC); // رنگ بنفش پیشنهادی برای تم تیره

    final unselectedItemColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

// =======================================================================================================================================

    final expandedItemBackgroundLight = selectedItemColorLight.withOpacity(0.9);

    final expandedItemBackgroundDark = selectedItemColorDark.withOpacity(0.8);

    double iconOnlyWidth =
        15.w > 60 ? 60 : 15.w; // عرض برای آیکون تنها (حداکثر ۶۰)

    double expandedWidth = _getExpandedWidth(context);

    double navBarHeight = 6.h > 20 ? 6.h : 25; // ارتفاع نوار

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.8.h),
      child: Container(
        height: navBarHeight,
        decoration: BoxDecoration(
          color: navBarBackgroundColor,

          borderRadius:
              BorderRadius.circular(30.0), // گردی بیشتر برای حالت کپسولی

          boxShadow: [
            BoxShadow(
              color: shadowColor,

              blurRadius: 12,

              spreadRadius: 0, // سایه نرم‌تر

              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(items.length, (index) {
            final item = items[index];

            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () => onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCirc,
                width: isSelected ? expandedWidth : iconOnlyWidth,
                height: navBarHeight * 0.75,
                padding: EdgeInsets.symmetric(horizontal: isSelected ? 3.w : 0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDarkMode
                          ? Colors.blueGrey.withOpacity(0.6)
                          : Color(0xFF455A64))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? Colors.white : unselectedItemColor,
                      size: isSelected ? 6.5.w : 6.w,
                    ),
                    if (isSelected) SizedBox(width: 2.w),
                    if (isSelected)
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: AutoSizeText(
                            item.text,

                            style: GoogleFonts.poppins(
                              // یا فونت فارسی

                              color: Colors.white,

                              fontSize: 16.sp, // اندازه فونت متن

                              fontWeight: FontWeight.w700,
                            ),

                            maxLines: 1,

                            minFontSize:
                                8, // حداقل اندازه فونت برای AutoSizeText

                            overflow: TextOverflow.ellipsis,

                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// -------- END: CustomFloatingNavBar --------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimationController;

  bool _isScanning = false;

  bool _isDarkMode = false;

  int _selectedNavBarIndex = 0;

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

  final List<NavItem> _navBarItems = const [
    NavItem(icon: Icons.home_filled, text: 'خانه', tooltip: 'صفحه اصلی'),
    NavItem(
        icon: Icons.document_scanner_outlined,
        text: 'RFID اسکن',
        tooltip: 'اسکن RFID'),
    NavItem(icon: Icons.search, text: 'جستجو', tooltip: 'جستجوی دارایی‌ها'),
    NavItem(
        icon: Icons.account_circle_outlined,
        text: ' حساب ',
        tooltip: 'تنظیمات کاربری'),
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

  void _toggleThemeMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
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

  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedNavBarIndex = index;
    });

    if (index == 0) {
      // Home
      context.go('/home');
    } else if (index == 1) {
      // Search
      context.go('/rfid_scan');
    } else if (index == 2) {
      context.go('/search_page');
    } else if (index == 3) {
      context.go('/profile_page');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Alert> sortedAlerts = List.from(_allAlerts);

    sortedAlerts.sort((a, b) {
      if (a.isCritical && !b.isCritical) return -1;

      if (!a.isCritical && b.isCritical) return 1;

      return b.timestamp.compareTo(a.timestamp);
    });

    final List<Alert> topAlerts = sortedAlerts.take(3).toList();

// ----- بهبود رنگ پس‌زمینه Scaffold -----

    final scaffoldBackgroundColor = _isDarkMode
        ? Colors.white12.withOpacity(0.15)
        : Colors.white; // خاکستری خیلی تیره یا خیلی روشن

    final cardItemBackgroundColor = _isDarkMode
        ? const Color(0xFF2C2C2E)
        : Colors.white; // برای _AlertItemCard

    final headerGradientColors = _isDarkMode
        ? [const Color(0xFF232325), const Color(0xFF2D2D2F)]
        : [const Color(0xFF263238), const Color(0xFF455A64)];

    final headerTextColor = Colors.white;

    final sectionTitleColor = _isDarkMode
        ? Colors.white.withOpacity(0.9)
        : Colors.black.withOpacity(0.9);

    final seeAllButtonColor = _isDarkMode
        ? const Color(0xFFBB86FC)
        : (Theme.of(context).primaryColor ?? Colors.blue);

    final emptyStateIconColor =
        _isDarkMode ? Colors.green.shade300 : Colors.green.shade600;

    final emptyStateTextColor = _isDarkMode
        ? Colors.white.withOpacity(0.75)
        : Colors.black.withOpacity(0.75);

    final emptyStateCardBackground = _isDarkMode
        ? const Color(0xFF2C2C2E).withOpacity(0.8)
        : Colors.grey.shade100;

    final currentOverviewDataList =
        _isDarkMode ? _overviewCardDataListDark : _overviewCardDataListLight;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false, // برای اینکه SafeArea با نویگیشن بار شناور تداخل نکند

        child: SingleChildScrollView(
// physics: ,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
// Header (بدون تغییر زیاد)

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
                            _isDarkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            color: headerTextColor,
                          ),
                          onPressed: _toggleThemeMode,
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
                      children: List.generate(currentOverviewDataList.length,
                          (index) {
                        return _OverviewCard(
                          data: currentOverviewDataList[index],
                          index: index,
                          isDarkMode: _isDarkMode,
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
                      children:
                          List.generate(_actionButtonDataList.length, (index) {
                        return _ActionButton(
                          data: _actionButtonDataList[index],
                          index: index,
                          isDarkMode: _isDarkMode,
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
                    if (_allAlerts.length > topAlerts.length &&
                        topAlerts.isNotEmpty)
                      TextButton(
                        onPressed: _navigateToAllAlertsPage,
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h)),
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

                    return _AlertItemCard(
                      alert: alert,
                      onTap: () => _navigateToAlertDetails(alert),
                      index: index,
                      isDarkMode: _isDarkMode,
                    );
                  },
                ),

              SizedBox(height: 12.h), // فضای بیشتر برای نویگیشن بار شناور
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomFloatingNavBar(
        isDarkMode: _isDarkMode,
        selectedIndex: _selectedNavBarIndex,
        onItemTapped: _onNavBarItemTapped,
        items: _navBarItems,
      ),
    );
  }
}
