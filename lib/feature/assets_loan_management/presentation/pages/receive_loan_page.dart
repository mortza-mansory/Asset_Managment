import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';

class ReceiveLoanPage extends StatelessWidget {
  const ReceiveLoanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final qrData = 'user_id:12345';
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        title: Text(l10n.receiveLoanTitle, style: GoogleFonts.poppins()),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.receiveLoanSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13.sp, color: secondaryTextColor, height: 1.6),
            ),
            SizedBox(height: 5.h),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child:Container(
                  width: 60.w,
                  height: 60.w,
                  color: Colors.black26,
                )
                // QrImageView(
                //   data: qrData,
                //   version: QrVersions.auto,
                //   size: 60.w,
                // ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              l10n.yourUniqueCode,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11.sp, color: secondaryTextColor),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}