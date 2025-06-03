import 'dart:async';
import 'dart:math';
import 'package:assetsrfid/feature/theme/bloc/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';

class ScannedRfidItem {
  final String id;
  final String name;
  final String type;
  final IconData iconData;
  final DateTime timestamp;
  final Map<String, String> details;
  final Color itemColor;

  ScannedRfidItem({
    required this.id,
    required this.name,
    required this.type,
    required this.iconData,
    required this.timestamp,
    required this.details,
    required this.itemColor,
  });
}

class RfidScanPage extends StatefulWidget {
  const RfidScanPage({super.key});

  @override
  State<RfidScanPage> createState() => _RfidScanPageState();
}

class _RfidScanPageState extends State<RfidScanPage>
    with TickerProviderStateMixin {
  bool _pageIsLoading = true;
  bool _isScanning = false;
  final List<ScannedRfidItem> _scannedItems = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late AnimationController _scannerIconController;
  Timer? _scanSimulatorTimer;

  final List<Map<String, dynamic>> _mockAssetPool = [
    {
      'name': 'لپ‌تاپ مدیریتی XPS 15',
      'type': 'لپ‌تاپ',
      'icon': Icons.laptop_mac_outlined,
      'color': Colors.blueAccent.shade400,
      'details': {
        'پردازنده': 'Core i9',
        'رم': '32GB',
        'حافظه': '1TB SSD',
        'کد اموال': 'LP-00125'
      }
    },
    {
      'name': 'هارد اکسترنال WD Elements',
      'type': 'هارد دیسک',
      'icon': Icons.save_outlined,
      'color': Colors.orangeAccent.shade400,
      'details': {
        'ظرفیت': '2TB',
        'رابط': 'USB 3.0',
        'شماره سریال': 'WD-SN550-2023-07'
      }
    },
    {
      'name': 'فلش مموری SanDisk Ultra',
      'type': 'فلش مموری',
      'icon': Icons.usb_outlined,
      'color': Colors.greenAccent.shade700,
      'details': {
        'ظرفیت': '128GB',
        'سرعت': 'USB 3.1',
        'پارت نامبر': 'SDCZ48-128G'
      }
    },
    {
      'name': 'دریل شارژی Bosch',
      'type': 'ابزار برقی',
      'icon': Icons.build_circle_outlined,
      'color': Colors.redAccent.shade400,
      'details': {
        'ولتاژ': '18V',
        'مدل': 'GBH 18V-26',
        'تاریخ خرید': '1402/05/10'
      }
    },
    {
      'name': 'گاوصندوق دیجیتال اثر',
      'type': 'گاوصندوق',
      'icon': Icons.security_outlined,
      'color': Colors.purpleAccent.shade400,
      'details': {
        'ابعاد': '50x40x30 cm',
        'رمز': 'دارد',
        'محل استقرار': 'اتاق مدیرعامل'
      }
    },
    {
      'name': 'مانیتور Samsung Odyssey G7',
      'type': 'مانیتور',
      'icon': Icons.desktop_windows_outlined,
      'color': Colors.tealAccent.shade400,
      'details': {
        'اندازه': '27 اینچ',
        'رزولوشن': 'QHD',
        'نرخ بروزرسانی': '240Hz'
      }
    },
    {
      'name': 'پرینتر HP LaserJet Pro M404dn',
      'type': 'پرینتر',
      'icon': Icons.print_outlined,
      'color': Colors.cyanAccent.shade700,
      'details': {
        'نوع': 'لیزری سیاه‌وسفید',
        'قابلیت': 'شبکه، چاپ دوطرفه',
        'وضعیت کارتریج': '75%'
      }
    },
    {
      'name': 'تبلت Apple iPad Pro',
      'type': 'تبلت',
      'icon': Icons.tablet_mac_outlined,
      'color': Colors.indigoAccent.shade200,
      'details': {'حافظه': '256GB', 'مدل': 'M2 Chip', 'رنگ': 'خاکستری فضایی'}
    },
    {
      'name': 'دوربین Nikon Z6 II',
      'type': 'دوربین عکاسی',
      'icon': Icons.camera_alt_outlined,
      'color': Colors.pinkAccent.shade200,
      'details': {
        'نوع سنسور': 'Full-Frame',
        'لنز': '24-70mm f/4',
        'کارت حافظه': 'Dual Slot'
      }
    },
  ];
  int _mockAssetIndex = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _scannerIconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _pageIsLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scannerIconController.dispose();
    _scanSimulatorTimer?.cancel();
    super.dispose();
  }

  void _toggleScan() {
    if (_isScanning) {
      _stopScan();
    } else {
      _startMockScan();
    }
  }

  void _startMockScan() {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      if (_mockAssetIndex >= _mockAssetPool.length) {
        _mockAssetIndex = 0;
      }
    });

    _scanSimulatorTimer = Timer.periodic(
        Duration(milliseconds: 1000 + _random.nextInt(1000)), (timer) {
      if (!_isScanning || _mockAssetIndex >= _mockAssetPool.length) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
          if (_mockAssetIndex >= _mockAssetPool.length &&
              _scannedItems.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تمام آیتم‌های نمونه اسکن شدند.',
                    style: GoogleFonts.poppins(color: Colors.white)),
                backgroundColor: context.read<ThemeState>().isDarkMode
                    ? Colors.grey.shade800
                    : Colors.blueGrey.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(2.w),
              ),
            );
          } else if (_scannedItems.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'اسکن متوقف شد. ${_scannedItems.length} آیتم یافت شد.',
                    style: GoogleFonts.poppins(color: Colors.white)),
                backgroundColor: context.read<ThemeState>().isDarkMode
                    ? Colors.grey.shade800
                    : Colors.blueGrey.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(2.w),
              ),
            );
          }
        }
        return;
      }

      if (mounted) {
        final mockItemData = _mockAssetPool[_mockAssetIndex];
        final newItem = ScannedRfidItem(
          id: 'RFID_TAG_${DateTime.now().millisecondsSinceEpoch}_$_mockAssetIndex',
          name: '${mockItemData['name']}',
          type: mockItemData['type'],
          iconData: mockItemData['icon'],
          timestamp: DateTime.now(),
          details: Map<String, String>.from(mockItemData['details']),
          itemColor: mockItemData['color'],
        );
        _addScannedItemToList(newItem);
        _mockAssetIndex++;
      }
    });
  }

  void _stopScan() {
    if (!_isScanning) return;
    _scanSimulatorTimer?.cancel();
    setState(() {
      _isScanning = false;
    });
  }

  void _addScannedItemToList(ScannedRfidItem item) {
    if (mounted) {
      if (!_scannedItems.any((existingItem) =>
          existingItem.name == item.name && existingItem.type == item.type)) {
        _scannedItems.insert(0, item);
        _listKey.currentState
            ?.insertItem(0, duration: const Duration(milliseconds: 450));
      }
    }
  }

  void _showItemDetails(BuildContext context, ScannedRfidItem item) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final detailsTextColor = isDarkMode
        ? Colors.white.withOpacity(0.85)
        : Colors.black.withOpacity(0.75);
    final detailsValueColor = isDarkMode ? Colors.white : Colors.black;
    final modalBackgroundColor =
        isDarkMode ? const Color(0xFF252528) : Colors.grey.shade50;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: modalBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
                children: [
                  Center(
                    child: Container(
                      width: 12.w,
                      height: 0.7.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: item.itemColor.withOpacity(0.15),
                        radius: 6.w,
                        child: Icon(item.iconData,
                            color: item.itemColor, size: 7.w),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: AutoSizeText(
                          item.name,
                          style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? Colors.white : Colors.black87),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  _buildDetailRow('نوع:', item.type, detailsTextColor,
                      detailsValueColor, isDarkMode),
                  _buildDetailRow(
                      'زمان اسکن:',
                      '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}:${item.timestamp.second.toString().padLeft(2, '0')} - ${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year}',
                      detailsTextColor,
                      detailsValueColor,
                      isDarkMode),
                  SizedBox(height: 2.5.h),
                  Text(
                    'جزئیات:',
                    style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black87),
                  ),
                  SizedBox(height: 1.h),
                  ...item.details.entries.map((entry) => _buildDetailRow(
                      '${entry.key}:',
                      entry.value,
                      detailsTextColor,
                      detailsValueColor,
                      isDarkMode,
                      isDetailEntry: true)),
                  SizedBox(height: 2.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color labelColor,
      Color valueColor, bool isDarkMode,
      {bool isDetailEntry = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDetailEntry ? 0.6.h : 0.4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  color: labelColor,
                  fontWeight:
                      isDetailEntry ? FontWeight.w500 : FontWeight.normal)),
          SizedBox(width: 1.5.w),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      color: valueColor,
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode
        ? Colors.white12.withOpacity(0.15)
        : Colors.white;
    final appBarBackgroundColor =
        isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F);
    final headerTextColor = Colors.white;
    final sectionTitleColor = isDarkMode
        ? Colors.white.withOpacity(0.9)
        : Colors.black.withOpacity(0.9);
    final emptyStateIconColor =
        isDarkMode ? Colors.blueGrey.shade200 : Colors.blueGrey.shade500;
    final emptyStateTextColor = isDarkMode
        ? Colors.white.withOpacity(0.65)
        : Colors.black.withOpacity(0.65);
    final scanButtonTextColor = isDarkMode ? Colors.black : Colors.white;

    if (_pageIsLoading) {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade600),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: appBarBackgroundColor,
                boxShadow: isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 20.sp,
                  ),

                  Text(
                    'اسکن RFID',
                    style: GoogleFonts.poppins(
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w600,
                      color: headerTextColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 3.w, left: 1.w),
                    child: AnimatedBuilder(
                      animation: _scannerIconController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _isScanning
                              ? (0.6 + _scannerIconController.value * 0.4)
                              : 0.75,
                          child: Icon(
                            Icons.nfc_rounded,
                            color: _isScanning
                                ? (isDarkMode
                                    ? Colors.tealAccent.shade100
                                    : Colors.tealAccent.shade200)
                                : headerTextColor.withOpacity(0.75),
                            size: 7.5.w,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.8.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? appBarBackgroundColor.withOpacity(0.6)
                    : Colors.white,
                boxShadow: isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      _isScanning
                          ? 'در حال اسکن...'
                          : (_scannedItems.isEmpty
                              ? 'آماده برای اسکن'
                              : '${_scannedItems.length} آیتم یافت شد'),
                      style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        color: isDarkMode
                            ? headerTextColor.withOpacity(0.85)
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      minFontSize: 9,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton.icon(
                    onPressed: _toggleScan,
                    icon: Icon(
                      _isScanning
                          ? Icons.stop_circle_outlined
                          : Icons.document_scanner_outlined,
                      size: 5.w,
                      color: _isScanning
                          ? (isDarkMode ? Colors.white : Colors.white)
                          : scanButtonTextColor,
                    ),
                    label: Text(
                      _isScanning ? 'توقف' : 'شروع اسکن',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                        color: _isScanning
                            ? (isDarkMode ? Colors.white : Colors.white)
                            : scanButtonTextColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isScanning
                          ? (isDarkMode
                              ? Colors.redAccent.shade200.withOpacity(0.9)
                              : Colors.red.shade400)
                          : (isDarkMode
                              ? Colors.tealAccent.shade100
                              : Colors.teal.shade500),
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.5.w, vertical: 1.1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: _isScanning ? 2 : 1,
                    ),
                  )
                      .animate(target: _isScanning ? 1 : 0)
                      .shake(
                          hz: _isScanning ? 2 : 0,
                          duration: 200.ms,
                          curve: Curves.easeInOut)
                      .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.03, 1.03),
                          duration: 150.ms,
                          curve: Curves.easeOut)
                      .then()
                      .scale(
                          begin: const Offset(1.03, 1.03),
                          end: const Offset(1, 1),
                          duration: 150.ms,
                          curve: Curves.easeIn),
                ],
              ),
            ).animate().fadeIn(duration: 250.ms).slideY(
                begin: -0.15,
                end: 0,
                duration: 250.ms,
                curve: Curves.easeOutCirc),
            Expanded(
              child: _scannedItems.isEmpty && !_isScanning
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.document_scanner_outlined,
                                size: 22.w, color: emptyStateIconColor),
                            SizedBox(height: 2.5.h),
                            Text(
                              'هیچ آیتمی اسکن نشده است.\nبرای شروع، دکمه "شروع اسکن" را فشار دهید.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 12.5.sp,
                                  color: emptyStateTextColor,
                                  height: 1.6),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 350.ms).scale(
                          delay: 200.ms,
                          begin: const Offset(0.85, 0.85),
                          curve: Curves.elasticOut),
                    )
                  : AnimatedList(
                      key: _listKey,
                      padding: EdgeInsets.fromLTRB(3.w, 1.5.h, 3.w, 10.h),
                      initialItemCount: _scannedItems.length,
                      itemBuilder: (context, index, animation) {
                        final item = _scannedItems[index];
                        return _buildListItem(context, item, animation, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildListItem(BuildContext context, ScannedRfidItem item,
      Animation<double> animation, int listIndex) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF2C2D30) : Colors.white;
    final titleColor = isDarkMode
        ? Colors.white.withOpacity(0.95)
        : Colors.black.withOpacity(0.9);
    final subtitleColor = isDarkMode
        ? Colors.white.withOpacity(0.65)
        : Colors.black.withOpacity(0.6);
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.2)
        : Colors.grey.withOpacity(0.25);

    final cardAnimation =
        CurvedAnimation(parent: animation, curve: Curves.easeInOutExpo);

    return SizeTransition(
      sizeFactor: cardAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.6, 0),
          end: Offset.zero,
        ).animate(cardAnimation),
        child: FadeTransition(
          opacity: cardAnimation,
          child: Card(
            color: cardBackgroundColor,
            elevation: isDarkMode ? 2.0 : 3.0,
            shadowColor: shadowColor,
            margin: EdgeInsets.symmetric(vertical: 0.7.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
              side: BorderSide(
                  color: item.itemColor.withOpacity(isDarkMode ? 0.5 : 0.7),
                  width: 1.2),
            ),
            child: InkWell(
              onTap: () => _showItemDetails(context, item),
              borderRadius: BorderRadius.circular(14.0),
              splashColor: item.itemColor.withOpacity(0.1),
              highlightColor: item.itemColor.withOpacity(0.05),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.6.h),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: item.itemColor.withOpacity(0.12),
                      radius: 5.5.w,
                      child:
                          Icon(item.iconData, color: item.itemColor, size: 6.w),
                    ),
                    SizedBox(width: 3.5.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            item.name,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.6.h),
                          Text(
                            '${item.type} • ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: subtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 4.w, color: subtitleColor.withOpacity(0.6)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
