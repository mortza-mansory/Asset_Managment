import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:assetsrfid/feature/auth/presentation/bloc/auth_event.dart';
import 'package:assetsrfid/feature/auth/presentation/bloc/auth_state.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OtpPage extends StatefulWidget {
  final String tempToken;
  final int userId;

  const OtpPage({
    super.key,
    required this.tempToken,
    required this.userId,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _enteredOtp = "";

  void _handleSuccessNavigation() {
    context.go('/role_selection');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.87);
    final secondaryTextColor =
    isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final scaffoldBackgroundColor =
    isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);

    final fillColor = isDarkMode
        ? Colors.black.withOpacity(0.18)
        : Colors.grey.shade100.withOpacity(0.8);
    final enabledBorderColor =
    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final focusedBorderColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: primaryTextColor.withOpacity(0.8)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Text(
                context.l10n.otpTitle,
                style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor),
              ).animate().fadeIn(delay: 200.ms).slideX(
                  begin: -0.1, duration: 300.ms),
              SizedBox(height: 1.h),
              Text(
                context.l10n.otpSubtitle,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500),
              ).animate().fadeIn(delay: 300.ms).slideX(
                  begin: -0.1, duration: 300.ms),
              SizedBox(height: 6.h),
              OtpTextField(
                numberOfFields: 6,
                fieldWidth: 12.w,
                keyboardType: TextInputType.number,
                textStyle: GoogleFonts.poppins(
                    fontSize: 16.sp, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: "",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                filled: true,
                fillColor: fillColor,
                borderColor: enabledBorderColor,
                focusedBorderColor: focusedBorderColor,
                borderRadius: BorderRadius.circular(12.0),
                showFieldAsBox: true,
                onSubmit: (String verificationCode) {
                  setState(() {
                    _enteredOtp = verificationCode;
                  });
                  if (_enteredOtp.length == 6) {
                    context.read<AuthBloc>().add(
                      VerifyOtpEvent(
                        userId: widget.userId,
                        tempToken: widget.tempToken,
                        otp: _enteredOtp,
                      ),
                    );
                  }
                },
              ).animate().fadeIn(delay: 400.ms).slideY(
                  begin: 0.2, duration: 300.ms, curve: Curves.easeOut),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: () {},
                child: Text(context.l10n.otpResendCode,
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600)),
              ).animate().fadeIn(delay: 500.ms),
              SizedBox(height: 4.h),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthLoginSuccess) {
                    _handleSuccessNavigation();
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  return NewCustomButton(
                    backgroundColor: Colors.blueGrey,
                    text: context.l10n.otpConfirmButton,
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (_enteredOtp.length == 6) {
                        context.read<AuthBloc>().add(
                          VerifyOtpEvent(
                            userId: widget.userId,
                            tempToken: widget.tempToken,
                            otp: _enteredOtp,
                          ),
                        );
                      }
                    },
                    animationDelay: 600.ms,
                  ).animate().fadeIn(delay: 600.ms).slideY(
                      begin: 0.2, duration: 300.ms, curve: Curves.easeOut);
                },
              ),
              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }
}