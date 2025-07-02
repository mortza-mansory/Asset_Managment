import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NewCustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final Duration animationDelay;

  const NewCustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.maxLength,
    this.focusNode,
    this.autofocus = false,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final fillColor = isDarkMode ? Colors.black.withOpacity(0.18) : Colors.grey.shade100.withOpacity(0.8);
    final borderColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final focusedBorderColor =  isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final iconColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final textColor = isDarkMode ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.87);
    final labelColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final errorColor = Theme.of(context).colorScheme.error;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      maxLength: maxLength,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      style: GoogleFonts.poppins(fontSize: 12.5.sp, color: textColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: labelColor, fontWeight: FontWeight.w500),
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: labelColor.withOpacity(0.7)),
        filled: true,
        fillColor: fillColor,
        prefixIcon: prefixIcon != null
            ? Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Icon(prefixIcon, color: iconColor, size: 5.5.w),
        )
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
          icon: Icon(suffixIcon, color: iconColor, size: 5.5.w),
          onPressed: onSuffixTap,
        )
            : null,
        counterText: "",
        contentPadding: EdgeInsets.symmetric(vertical: 2.2.h, horizontal: 4.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: borderColor.withOpacity(0.8), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: errorColor, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: errorColor, width: 1.8),
        ),
        errorStyle: GoogleFonts.poppins(fontSize: 9.5.sp, color: errorColor, fontWeight: FontWeight.w500),
      ),
    );
  }
}