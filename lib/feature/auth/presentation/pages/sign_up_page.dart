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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: primaryTextColor.withOpacity(0.8)),
          onPressed: () => context.go('/modal_start'),
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
                SizedBox(height: 2.h),
                Text(
                  context.l10n.signUpTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(
                    begin: -0.1, duration: 300.ms),
                SizedBox(height: 1.h),
                Text(
                  context.l10n.signUpSubtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideX(
                    begin: -0.1, duration: 300.ms),
                SizedBox(height: 5.h),
                NewCustomTextField(
                    controller: _usernameController,
                    labelText: context.l10n.usernameLabel,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) =>
                    v == null || v.isEmpty ? context.l10n.usernameValidationError : null,
                    animationDelay: 400.ms,
                    autofillHints: const [AutofillHints.newUsername]),
                SizedBox(height: 2.5.h),
                NewCustomTextField(
                    controller: _passwordController,
                    labelText: context.l10n.passwordLabel,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) {
                      if (v == null || v.isEmpty) return context.l10n.passwordValidationError;
                      if (v.length < 6) return context.l10n.passwordLengthValidationError;
                      return null;
                    },
                    animationDelay: 500.ms,
                    autofillHints: const [AutofillHints.newPassword]),
                SizedBox(height: 2.5.h),
                NewCustomTextField(
                    controller: _confirmPasswordController,
                    labelText: context.l10n.confirmPasswordLabel,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixTap: () => setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword),
                    validator: (v) => v != _passwordController.text
                        ? context.l10n.confirmPasswordValidationError
                        : null,
                    animationDelay: 600.ms),
                SizedBox(height: 2.5.h),
                NewCustomTextField(
                    controller: _phoneNumberController,
                    labelText: context.l10n.phoneNumberLabel,
                    prefixIcon: Icons.phone_iphone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                    v == null || v.isEmpty ? context.l10n.phoneNumberValidationError : null,
                    animationDelay: 700.ms,
                    autofillHints: const [AutofillHints.telephoneNumber]),
                SizedBox(height: 2.5.h),
                NewCustomTextField(
                    controller: _emailController,
                    labelText: 'ایمیل (اختیاری)',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'لطفا فرمت ایمیل را صحیح وارد کنید';
                      }
                      return null;
                    },
                    animationDelay: 800.ms),
                SizedBox(height: 4.h),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthOtpSent) {
                      final extra = {
                        'userId': state.tempTokenEntity.userId,
                        'isForLogin': false,
                      };
                      context.go('/otp/${state.tempTokenEntity.tempToken}', extra: extra);
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message, style: GoogleFonts.poppins()),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return NewCustomButton(
                      text: context.l10n.signUpButton,
                      backgroundColor: Colors.blueGrey,
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            SignUpEvent(
                              username: _usernameController.text,
                              password: _passwordController.text,
                              phoneNum: _phoneNumberController.text,
                              email: _emailController.text.isEmpty ? null : _emailController.text,
                            ),
                          );
                        }
                      },
                      animationDelay: 1000.ms,
                    );
                  },
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.l10n.alreadyHaveAnAccount,
                        style: GoogleFonts.poppins(
                            fontSize: 11.5.sp, color: secondaryTextColor)),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        context.l10n.logIn,
                        style: GoogleFonts.poppins(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1100.ms),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}