import 'package:assetsrfid/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:assetsrfid/shared/widgets/custom_text_field.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // اضافه شده

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.87);
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA); // رنگ پس‌زمینه هماهنگ

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                Center(
                  child: Icon(Icons.track_changes_rounded,
                     size: 15.w,
                    color:  Colors.grey.shade600
                  )
                   .animate().fadeIn(delay: 100.ms).scale(duration: 400.ms, curve: Curves.elasticOut),
                 ),
                 SizedBox(height: 6.h),
                Text(
                  'خوش آمدید!',
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, duration: 300.ms),
                SizedBox(height: 1.h),
                Text(
                  'برای ادامه وارد شوید.',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, duration: 300.ms),
                SizedBox(height: 6.h),

                NewCustomTextField(
                  controller: _usernameController,
                  labelText: 'نام کاربری',
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.text,
                  autofillHints: const [AutofillHints.username],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا نام کاربری خود را وارد کنید';
                    }
                    return null;
                  },
                  animationDelay: 400.ms,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut),

                SizedBox(height: 2.5.h),

                NewCustomTextField(
                  controller: _passwordController,
                  labelText: 'رمز عبور',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا رمز عبور خود را وارد کنید';
                    }
                    return null;
                  },
                  animationDelay: 500.ms,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut),

                SizedBox(height: 1.h),
                 Align(
                  alignment: Alignment.centerRight,
                   child: TextButton(
                     onPressed: () { /* TODO: Navigate to forgot password */ },
                     child: Text('فراموشی رمز عبور؟', style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                   ),
                 ).animate().fadeIn(delay: 600.ms),

                SizedBox(height: 4.h),

                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthLoginSuccess) {
                      context.go('/otp/${state.tempToken}');
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
                      text: 'ورود',
                      backgroundColor: Colors.blueGrey,
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            LoginEvent(
                              username: _usernameController.text,
                              password: _passwordController.text,
                            ),
                          );
                        }
                      },
                      animationDelay: 700.ms,
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut);
                  },
                ),

                SizedBox(height: 3.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('حساب کاربری ندارید؟', style: GoogleFonts.poppins(fontSize: 14.sp, color: secondaryTextColor)),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: Text(
                        'ثبت نام کنید',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}