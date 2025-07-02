import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:assetsrfid/feature/auth/presentation/bloc/auth_event.dart';
import 'package:assetsrfid/feature/auth/presentation/bloc/auth_state.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:assetsrfid/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int? _userIdForReset;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendCode() {
    // فقط فیلد اول را چک می‌کنیم
    if (_emailOrPhoneController.text.isNotEmpty) {
      context
          .read<AuthBloc>()
          .add(RequestResetCodeEvent(_emailOrPhoneController.text));
    } else {
      // اگر خالی بود، یک خطا به صورت دستی نمایش می‌دهیم
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.emailOrPhoneValidationError, style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange.shade800,
      ));
    }
  }

  void _changePassword() {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      // اگر فرم معتبر نبود، یک اسنک‌بار کلی نمایش می‌دهیم
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("لطفاً تمام فیلدهای لازم را به درستی پر کنید.", style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange.shade800,
      ));
      return;
    }

    if (_userIdForReset != null) {
      context.read<AuthBloc>().add(VerifyResetCodeEvent(
        userId: _userIdForReset!,
        code: _otpController.text,
        newPassword: _passwordController.text,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("خطا: ابتدا باید کد تایید را دریافت کنید."),
      ));
    }
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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ResetCodeSent) {
          setState(() {
            _userIdForReset = state.resetCodeEntity.userId;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.codeSentSnackbar, style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ));
        } else if (state is PasswordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.passwordChangedSuccessSnackbar, style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ));
          context.go('/login');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: GoogleFonts.poppins()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
            onPressed: () => context.go("/login"),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  Text(
                    context.l10n.forgotPasswordPageTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                  SizedBox(height: 1.h),
                  Text(
                    context.l10n.forgotPasswordPageSubtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: NewCustomTextField(
                          controller: _emailOrPhoneController,
                          labelText: context.l10n.emailOrPhoneLabel,
                          prefixIcon: Icons.contact_mail_outlined,
                          validator: (v) => v == null || v.isEmpty
                              ? context.l10n.emailOrPhoneValidationError
                              : null,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      SizedBox(
                        height: 7.h,
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading && _userIdForReset == null;
                            return ElevatedButton(
                              onPressed: isLoading ? null : _sendCode,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                                  foregroundColor: primaryTextColor,
                                  shadowColor: Colors.transparent,
                                  elevation: 0),
                              child: isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(context.l10n.sendCodeButton, style: GoogleFonts.poppins(fontSize: 11.sp)),
                            );
                          },
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms),
                  SizedBox(height: 2.5.h),
                  NewCustomTextField(
                    controller: _otpController,
                    labelText: context.l10n.otpLabel,
                    prefixIcon: Icons.sms_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return context.l10n.otpValidationError;
                      return null;
                    },
                  ),
                  SizedBox(height: 2.5.h),
                  NewCustomTextField(
                    controller: _passwordController,
                    labelText: context.l10n.passwordLabel,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) {
                      if (v == null || v.isEmpty) return context.l10n.passwordValidationError;
                      if (v.length < 6) return context.l10n.passwordLengthValidationError;
                      return null;
                    },
                  ),
                  SizedBox(height: 2.5.h),
                  NewCustomTextField(
                    controller: _confirmPasswordController,
                    labelText: context.l10n.confirmPasswordLabel,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    onSuffixTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    validator: (v) => v != _passwordController.text
                        ? context.l10n.confirmPasswordValidationError
                        : null,
                  ),
                  SizedBox(height: 6.h),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading && _userIdForReset != null;
                      return NewCustomButton(
                        text: context.l10n.changePasswordButton,
                        backgroundColor: Colors.blueGrey,
                        isLoading: isLoading,
                        onPressed: _changePassword,
                      );
                    },
                  ),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}