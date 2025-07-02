import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

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

class AlertItemCard extends StatelessWidget {
  final Alert alert;

  final VoidCallback onTap;

  final int index;

  final bool isDarkMode;

  const AlertItemCard({
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

      elevation: isDarkMode ? 1.5 : 2.5,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: alertSeverityColor.withOpacity(isDarkMode ? 0.7 : 1.0),
            width: 1.5),
      ),

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
