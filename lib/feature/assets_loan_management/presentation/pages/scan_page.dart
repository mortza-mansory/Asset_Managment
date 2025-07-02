import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

enum ScanMode { rfid, qrCode }

class ScanPage extends StatefulWidget {
  final ScanMode mode;
  const ScanPage({super.key, required this.mode});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _startScanSimulation();
  }

  void _startScanSimulation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final result = widget.mode == ScanMode.rfid
            ? 'لپ‌تاپ Dell XPS 15 (RFID-123)'
            : 'آقای محمدی (USER-456)';
        context.pop(result);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final isRfidMode = widget.mode == ScanMode.rfid;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        title: Text(isRfidMode ? l10n.scanPageTitleRfid : l10n.scanPageTitleQr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRfidMode)
              Animate(
                onPlay: (controller) => controller.repeat(),
                effects: [
                  ScaleEffect(
                      duration: 1500.ms,
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      curve: Curves.easeInOut),
                  FadeEffect(duration: 1500.ms, begin: 1.0, end: 0.0),
                ],
                child: const Icon(Icons.wifi_tethering,
                    size: 150, color: Colors.blueGrey),
              )
            else
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal.shade400, width: 4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_scanner_rounded,
                    size: 100, color: Colors.white),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .then(delay: 500.ms)
                  .tint(
                  color: Colors.white.withOpacity(0.3),
                  duration: 300.ms,
                  end: 0.2)
                  .then()
                  .tint(color: Colors.transparent, duration: 1000.ms),
            SizedBox(height: 4.h),
            Text(
              isRfidMode ? l10n.scanPageSearchingRfid : l10n.scanPageSearchingQr,
              style: GoogleFonts.poppins(
                  fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}