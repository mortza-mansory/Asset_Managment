import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_bloc.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_event.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_state.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final appBarBackgroundColor = isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F);
    final DropDownBackgroundColor = isDarkMode ? const Color(0xFF37474F) : const Color(
        0xFFFFFFFF);
    final headerTextColor = isDarkMode ? Colors.white : Colors.black45;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          BlocBuilder<LocalizationBloc, LocalizationState>(
            builder: (context, state) {
              return DropdownButton<Locale>(
                value: state.locale,
                icon: Icon(Icons.language, color: headerTextColor, size: 20.sp),
                underline: const SizedBox(),
                dropdownColor: DropDownBackgroundColor,
                items: const [
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('EN'),
                  ),
                  DropdownMenuItem(
                    value: Locale('fa'),
                    child: Text('FA'),
                  ),
                ],
                onChanged: (locale) {
                  if (locale != null) {
                    context.read<LocalizationBloc>().add(ChangeLocale(locale));
                  }
                },
                style: GoogleFonts.poppins(color: headerTextColor, fontSize: 12.sp),
              );
            },
          ),
          SizedBox(width: 2.w),
          IconButton(
            icon: Icon(
              size: 22.sp,
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: headerTextColor,
            ),
            onPressed: () {
              context.read<ThemeBloc>().toggleTheme();
            },
          ),
          SizedBox(width: 2.w),
        ],
      ),
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
                color: Colors.grey.shade600,
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(delay: 200.ms, duration: 800.ms, curve: Curves.elasticOut, begin: const Offset(0.7, 0.7)),
              SizedBox(height: 4.h),
              Text(
                context.l10n.modalWelcomeTitle,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutCirc),
              SizedBox(height: 1.5.h),
              Text(
                context.l10n.modalWelcomeSubtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12.5.sp,
                  color: secondaryTextColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutCirc),
              const Spacer(flex: 3),
              NewCustomButton(
                text: context.l10n.modalCreateAccount,
                onPressed: () => context.go('/signup'),
                backgroundColor: Colors.blueGrey,
                elevation: 4,
                animationDelay: 900.ms,
              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutExpo),
              SizedBox(height: 2.5.h),
              NewCustomButton(
                text: context.l10n.modalLogin,
                onPressed: () => context.go('/login'),
                backgroundColor: isDarkMode ? Colors.white.withOpacity(0.12) : Colors.blueGrey.withOpacity(0.15),
                textColor: isDarkMode ? Colors.white.withOpacity(0.85) : Colors.blueGrey,
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