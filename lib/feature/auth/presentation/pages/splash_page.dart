import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:assetsrfid/feature/auth/presentation/bloc/auth_event.dart';
import 'package:assetsrfid/feature/auth/presentation/bloc/auth_state.dart';
import 'package:assetsrfid/feature/auth/utils/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _initialCheckDone = false;

  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    if (!mounted) return;

    final tokenStorage = context.read<TokenStorage>();
    final accessToken = await tokenStorage.getAccessToken();

    if (!mounted) return;

    if (accessToken != null) {
      context.read<AuthBloc>().add(VerifyTokenEvent(accessToken));
    } else {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _initialCheckDone = true;
        });
        context.go('/modal_start');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor =
    isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);
    final primaryTextColor = isDarkMode
        ? Colors.white.withOpacity(0.9)
        : Colors.black.withOpacity(0.87);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (!mounted) return;
          if (state is TokenVerified) {
            context.go(state.isValid ? '/role_selection' : '/modal_start');
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.track_changes_rounded,
                size: 25.w,
                color: Colors.grey.shade600,
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                  delay: 200.ms,
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.5, 0.5))
                  .then(delay: 200.ms)
                  .shake(
                  hz: 2, duration: 300.ms, curve: Curves.easeInOutCubic),
              SizedBox(height: 3.h),
              Text(
                context.l10n.splashTitle,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                  letterSpacing: 0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCirc),
              SizedBox(height: 1.5.h),
              Text(
                context.l10n.splashLoading,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: primaryTextColor.withOpacity(0.7),
                ),
              )
                  .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
                  .fade(
                  delay: 1000.ms,
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                  begin: 0.3,
                  end: 0.7),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}