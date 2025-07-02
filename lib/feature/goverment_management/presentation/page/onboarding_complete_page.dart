import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class OnboardingCompletePage extends StatelessWidget {
  const OnboardingCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;

    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1E1E20) : const Color(0xFFF4F6F8);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.check_circle_outline_rounded, size: 30.w, color: Colors.green.shade400)
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut, begin: const Offset(0.5, 0.5))
                  .then(delay: 200.ms)
                  .shake(hz: 3, duration: 400.ms),
              SizedBox(height: 3.h),
              Text(
                context.l10n.onboardingCompleteTitle,
                style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                context.l10n.onboardingCompleteSubtitle,
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade600, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              NewCustomButton(
                text: context.l10n.goToDashboardButton,
                onPressed: () => context.go('/switch_company'),
                icon: Icons.arrow_forward_rounded,
                backgroundColor: Colors.blueGrey,
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}