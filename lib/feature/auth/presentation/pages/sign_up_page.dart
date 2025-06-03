import 'package:assetsrfid/feature/auth/presentation/bloc/auth_bloc.dart';
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
  final _governmentIdController = TextEditingController();
  final _governmentNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    _governmentIdController.dispose();
    _governmentNameController.dispose();
    super.dispose();
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
                  'ایجاد حساب کاربری',
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, duration: 300.ms),
                SizedBox(height: 1.h),
                Text(
                  'به جمع ما بپیوندید!',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, duration: 300.ms),
                SizedBox(height: 5.h),

                _buildTextField(_usernameController, 'نام کاربری', Icons.person_outline_rounded, validator: (v) => v == null || v.isEmpty ? 'نام کاربری را وارد کنید' : null, animationDelay: 400.ms, autofillHints: [AutofillHints.newUsername]),
                _buildTextField(_passwordController, 'رمز عبور', Icons.lock_outline_rounded, obscureText: _obscurePassword, suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, onSuffixTap: () => setState(()=> _obscurePassword = !_obscurePassword), validator: (v) { if (v==null || v.isEmpty) return 'رمز عبور را وارد کنید'; if (v.length < 6) return 'رمز عبور حداقل ۶ کاراکتر باشد'; return null;}, animationDelay: 500.ms, autofillHints: [AutofillHints.newPassword]),
                _buildTextField(_confirmPasswordController, 'تکرار رمز عبور', Icons.lock_outline_rounded, obscureText: _obscureConfirmPassword, suffixIcon: _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, onSuffixTap: () => setState(()=> _obscureConfirmPassword = !_obscureConfirmPassword), validator: (v) => v != _passwordController.text ? 'رمزهای عبور یکسان نیستند' : null, animationDelay: 600.ms),
                _buildTextField(_phoneNumberController, 'شماره تلفن همراه', Icons.phone_iphone_outlined, keyboardType: TextInputType.phone, validator: (v) => v == null || v.isEmpty ? 'شماره تلفن را وارد کنید' : null, animationDelay: 700.ms, autofillHints: [AutofillHints.telephoneNumber]),
                _buildTextField(_governmentNameController, 'نام سازمان/شرکت', Icons.apartment_outlined, animationDelay: 800.ms), // تغییر برچسب
                _buildTextField(_governmentIdController, 'کد اقتصادی/شناسه ملی (اختیاری)', Icons.badge_outlined, animationDelay: 900.ms), // تغییر برچسب

                SizedBox(height: 4.h),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSignUpSuccess) {
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
                      text: 'ثبت نام',
                      backgroundColor: Colors.blueGrey,
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            SignUpEvent(
                              username: _usernameController.text,
                              password: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
                              phoneNumber: _phoneNumberController.text,
                              governmentId: _governmentIdController.text.isEmpty ? null : _governmentIdController.text,
                              governmentName: _governmentNameController.text.isEmpty ? null : _governmentNameController.text,
                            ),
                          );
                        }
                      },
                      animationDelay: 1000.ms,
                    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut);
                  },
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('قبلاً ثبت‌نام کرده‌اید؟', style: GoogleFonts.poppins(fontSize: 11.5.sp, color: secondaryTextColor)),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'وارد شوید',
                        style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey),
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData prefixIcon,
      {FormFieldValidator<String>? validator,
        bool obscureText = false,
        IconData? suffixIcon,
        VoidCallback? onSuffixTap,
        TextInputType? keyboardType,
        Duration animationDelay = Duration.zero,
        Iterable<String>? autofillHints,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.5.h),
      child: NewCustomTextField(
        controller: controller,
        labelText: label,
        prefixIcon: prefixIcon,
        obscureText: obscureText,
        suffixIcon: suffixIcon,
        onSuffixTap: onSuffixTap,
        validator: validator,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        animationDelay: animationDelay,
      ),
    ).animate().fadeIn(delay: animationDelay).slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut);
  }
}