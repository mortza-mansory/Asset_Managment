import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NewCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? elevation;
  final IconData? icon;
  final Duration animationDelay;


  const NewCustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.elevation,
    this.icon,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Using primaryColor from the app's theme, assuming it's defined (e.g., a Teal color)
    final primaryAppColor = Theme.of(context).primaryColor;

    final defaultBackgroundColor = isDarkMode ? primaryAppColor.withOpacity(0.9) : primaryAppColor;
    final defaultTextColor = (backgroundColor ?? defaultBackgroundColor).computeLuminance() > 0.5
        ? Colors.black.withOpacity(0.8)
        : Colors.white;
    final finalTextColor = textColor ?? defaultTextColor;


    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 7.h, // Slightly taller for better tap target
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? defaultBackgroundColor,
          disabledBackgroundColor: (backgroundColor ?? defaultBackgroundColor).withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: isLoading ? 0 : (elevation ?? 3.5),
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          shadowColor: Colors.black.withOpacity(0.15),
        ),
        child: isLoading
            ? SizedBox(
          width: 3.5.h,
          height: 3.5.h,
          child: CircularProgressIndicator(
            strokeWidth: 2.8,
            valueColor: AlwaysStoppedAnimation<Color>(finalTextColor),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: finalTextColor, size: 5.w),
              SizedBox(width: 2.w),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: finalTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}