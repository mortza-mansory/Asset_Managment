import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ModalPage extends StatelessWidget {
  const ModalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.87);
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);
    final accentColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.track_changes_rounded,
                size: 22.w,
                color:  Colors.grey.shade600,
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(delay: 200.ms, duration: 800.ms, curve: Curves.elasticOut, begin: const Offset(0.7, 0.7)),

              SizedBox(height: 4.h),

              Text(
                'به سامانه هوشمند اموال خوش آمدید!',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutCirc),

              SizedBox(height: 1.5.h),

              Text(
                'اموال خود را به سادگی ردیابی و مدیریت کنید.',
                style: GoogleFonts.poppins(
                  fontSize: 12.5.sp,
                  color: secondaryTextColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutCirc),

              const Spacer(flex: 3),

              NewCustomButton(
                text: 'ایجاد حساب کاربری',
                onPressed: () => context.go('/signup'),
                backgroundColor:  Colors.blueGrey,
                elevation: 4,
                animationDelay: 900.ms,
              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutExpo),

              SizedBox(height: 2.5.h),

              NewCustomButton(
                text: 'ورود به حساب کاربری',
                onPressed: () => context.go('/login'),
                backgroundColor: isDarkMode ? Colors.white.withOpacity(0.12) : Colors.blueGrey.withOpacity(0.15),
                textColor: isDarkMode ? Colors.white.withOpacity(0.85) :  Colors.blueGrey,
                elevation: 2,
                animationDelay: 1100.ms,
              ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutExpo),

              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }
}
