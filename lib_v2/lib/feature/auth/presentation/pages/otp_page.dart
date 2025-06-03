import 'package:assetsrfid/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:assetsrfid/shared/widgets/custom_text_field.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpPage extends StatefulWidget {
  final String tempToken;

  const OtpPage({super.key, required this.tempToken});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showWelcomeModal(BuildContext originalContext) {
    final isDarkMode = Theme.of(originalContext).brightness == Brightness.dark;
    final dialogBackgroundColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.87);
    final secondaryTextColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

    showDialog(
      context: originalContext,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 1.h),
              Icon(Icons.check_circle_outline_rounded, size: 18.w, color: Colors.green.shade400)
                  .animate()
                  .scale(duration: 0.5.seconds, curve: Curves.elasticOut)
                  .then(delay: 0.2.seconds)
                  .shake(hz: 3, duration: 0.3.seconds),
              SizedBox(height: 2.5.h),
              Text(
                'خوش آمدید!',
                style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
              SizedBox(height: 1.h),
              Text(
                'حساب کاربری شما با موفقیت فعال شد.',
                style: GoogleFonts.poppins(fontSize: 12.sp, color: secondaryTextColor, height: 1.5),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              NewCustomButton(
                text: 'شروع استفاده از برنامه',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  originalContext.go('/home');
                },
                icon: Icons.rocket_launch_outlined,
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.87);
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor.withOpacity(0.8)),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Text(
                  'تایید کد یکبار مصرف',
                  style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, duration: 300.ms),
                SizedBox(height: 1.h),
                Text(
                  'کد ۶ رقمی ارسال شده به شماره همراه خود را وارد کنید.',
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: secondaryTextColor, fontWeight: FontWeight.w500),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, duration: 300.ms),
                SizedBox(height: 6.h),


                NewCustomTextField(
                  controller: _otpController,
                  labelText: 'کد تایید ۶ رقمی',
                  hintText: '• • • • • •',
                  prefixIcon: Icons.sms_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.length != 6) {
                      return 'لطفا کد ۶ رقمی را به طور کامل وارد کنید';
                    }
                    return null;
                  },
                  animationDelay: 400.ms,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut),

                 SizedBox(height: 2.h),
                 TextButton(
                   onPressed: () { /* TODO: Resend OTP logic */ },
                   child: Text('ارسال مجدد کد', style: GoogleFonts.poppins(fontSize: 11.sp, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                 ).animate().fadeIn(delay: 500.ms),

                SizedBox(height: 4.h),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthOtpVerified) {
                      _showWelcomeModal(context);
                    } else if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message, style: GoogleFonts.poppins()),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.all(2.w),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return NewCustomButton(
                      text: 'تایید و ادامه',
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            VerifyOtpEvent(
                              tempToken: widget.tempToken,
                              otp: _otpController.text,
                            ),
                          );
                        }
                      },
                      animationDelay: 600.ms,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut);
                  },
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}