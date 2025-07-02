import 'dart:async';
import 'dart:math';
import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ScannedItemData {
  final String name;
  final String code;
  final IconData icon;
  final bool isMatch;

  ScannedItemData({
    required this.name,
    required this.code,
    required this.icon,
    this.isMatch = false,
  });
}

class RfidValidationPage extends StatefulWidget {
  final int state;
  const RfidValidationPage({super.key, required this.state});

  @override
  State<RfidValidationPage> createState() => _RfidValidationPageState();
}

class _RfidValidationPageState extends State<RfidValidationPage>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<ScannedItemData> _scannedItems = [];
  Timer? _scanSimulatorTimer;
  bool _isScanCompleted = false;

  late AnimationController _appBarIconController;

  final ScannedItemData _expectedAsset = ScannedItemData(
      name: 'لپ‌تاپ Dell XPS 15',
      code: 'LP-00125',
      icon: Icons.laptop_mac_outlined,
      isMatch: true);

  final List<ScannedItemData> _mismatchPool = [
    ScannedItemData(
        name: 'دریل شارژی Bosch',
        code: 'T-0158',
        icon: Icons.build_circle_outlined),
    ScannedItemData(
        name: 'هارد اکسترنال WD',
        code: 'HD-0512',
        icon: Icons.save_outlined),
    ScannedItemData(
        name: 'مانیتور Samsung G7',
        code: 'MN-0098',
        icon: Icons.desktop_windows_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _appBarIconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _startSimulation();
  }

  @override
  void dispose() {
    _scanSimulatorTimer?.cancel();
    _appBarIconController.dispose();
    super.dispose();
  }

  void _startSimulation() {
    int scanCount = 0;
    const maxScans = 5;

    _scanSimulatorTimer =
        Timer.periodic(const Duration(milliseconds: 1800), (timer) {
          if (scanCount >= maxScans || _isScanCompleted) {
            timer.cancel();
            if (mounted) setState(() => _isScanCompleted = true);
            return;
          }

          ScannedItemData newItem;
          bool shouldStop = false;

          if (widget.state == 1 && scanCount == 3) {
            newItem = _expectedAsset;
            shouldStop = true;
          } else {
            newItem = _mismatchPool[Random().nextInt(_mismatchPool.length)];
          }

          if (mounted) {
            _scannedItems.insert(0, newItem);
            _listKey.currentState
                ?.insertItem(0, duration: const Duration(milliseconds: 500));
            if (shouldStop) {
              setState(() => _isScanCompleted = true);
              timer.cancel();
            }
          }
          scanCount++;
        });
  }

  void _restartScan() {
    for (int i = _scannedItems.length - 1; i >= 0; i--) {
      _listKey.currentState?.removeItem(
        i,
            (context, animation) =>
            _buildListItem(_scannedItems[i], animation, false),
        duration: const Duration(milliseconds: 300),
      );
    }
    setState(() {
      _scannedItems.clear();
      _isScanCompleted = false;
    });
    _startSimulation();
  }

  PreferredSizeWidget _buildCustomAppBar() {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final appBarBackgroundColor =
    isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final headerTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

    return PreferredSize(
      preferredSize: Size.fromHeight(15.h),
      child: Container(
        padding: EdgeInsets.only(top: 2.h),
        decoration: BoxDecoration(
          color: appBarBackgroundColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
                blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                    color: headerTextColor,
                  ),
                  Text(
                    l10n.rfidValidationPageTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w600,
                      color: headerTextColor,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _appBarIconController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: !_isScanCompleted
                            ? (0.6 + _appBarIconController.value * 0.4)
                            : 0.5,
                        child: Icon(
                          Icons.nfc_rounded,
                          color: !_isScanCompleted
                              ? (isDarkMode
                              ? Colors.tealAccent.shade100
                              : Colors.teal.shade400)
                              : headerTextColor.withOpacity(0.5),
                          size: 7.5.w,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
              child: _buildExpectedAssetCard(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor =
    isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: _buildCustomAppBar(),
      body: AnimatedList(
        key: _listKey,
        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
        initialItemCount: _scannedItems.length,
        itemBuilder: (context, index, animation) {
          final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
          return _buildListItem(_scannedItems[index], animation, isDarkMode);
        },
      ),
    );
  }

  Widget _buildExpectedAssetCard(bool isDarkMode) {
    final l10n = context.l10n;
    final primaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;

    return Row(
      children: [
        Icon(_expectedAsset.icon, size: 8.w, color: primaryTextColor),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.rfidExpectedAsset,
                style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold),
              ),
              Text(_expectedAsset.name,
                  style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor)),
              Text(_expectedAsset.code,
                  style: GoogleFonts.poppins(
                      fontSize: 11.sp, color: secondaryTextColor)),
            ],
          ),
        ),
        SizedBox(width: 1.w),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: _isScanCompleted
              ? IconButton(
            key: const ValueKey('restart_icon'),
            icon: Icon(Icons.replay_circle_filled_rounded,
                color: primaryTextColor, size: 8.w),
            onPressed: _restartScan,
          )
              : SizedBox(
            key: const ValueKey('spinner'),
            height: 6.w,
            width: 6.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        )
      ],
    );
  }

  Widget _buildListItem(
      ScannedItemData item, Animation<double> animation, bool isDarkMode) {
    // final cardBackgroundColor = item.isMatch
    //     ? (isDarkMode
    //     ? Colors.green.withOpacity(0.1)
    //     : Colors.green.withOpacity(0.08))
    //     : (isDarkMode
    //     ? Colors.red.withOpacity(0.1)
    //     : Colors.red.withOpacity(0.08));

    final borderColor =
    item.isMatch ? Colors.green.shade400 : Colors.red.shade400;

    final icon =
    item.isMatch ? Icons.check_circle_rounded : Icons.cancel_rounded;

    final primaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

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
            color: isDarkMode ? Colors.white12 : Colors.white,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor, width: 1.5),
            ),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Row(
                children: [
                  Icon(icon, color: borderColor, size: 8.w),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor)),
                        Text(item.code,
                            style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: primaryTextColor.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}