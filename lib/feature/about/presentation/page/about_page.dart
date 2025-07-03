import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF4F6F8);
    final cardColor = isDarkMode ? const Color(0xFF232428) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.aboutAppTitle, style: GoogleFonts.poppins()),
        backgroundColor: cardColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.track_changes_rounded, size: 25.w, color: Colors.teal.shade300)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(delay: 200.ms, curve: Curves.elasticOut),
            SizedBox(height: 2.h),
            Text(
              "Asset RFID Manager",
              style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            SizedBox(height: 4.h),
            Card(
              color: cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    _buildInfoRow(l10n.aboutAppVersion, "1.0.0", Icons.info_outline, primaryTextColor),
                    const Divider(),
                    _buildInfoRow(l10n.aboutAppDeveloper, "Morteza Mansouri", Icons.person_outline, primaryTextColor),
                  ],
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              l10n.aboutAppDescription,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11.sp, color: primaryTextColor.withOpacity(0.8), height: 1.8),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal.shade300),
          SizedBox(width: 4.w),
          Text(title, style: GoogleFonts.poppins(fontSize: 12.sp, color: textColor.withOpacity(0.8))),
          const Spacer(),
          Text(value, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }
}