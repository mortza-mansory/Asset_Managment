import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_state.dart';

class UserProfileData {
  final String fullName;
  final String role;
  final String organizationName;
  final String? department;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;

  UserProfileData({
    required this.fullName,
    required this.role,
    required this.organizationName,
    this.department,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
  });
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _pageIsLoading = true;
  late UserProfileData _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _pageIsLoading = false);
    });
  }

  void _loadUserData() {
    _userData = UserProfileData(
      fullName: "جناب آقای سید امیرحسین رضوی",
      role: "مدیر ارشد سامانه هوشمند اموال",
      organizationName: "شرکت دانش‌بنیان پرتو پردازشگران آویژه",
      department: "تیم توسعه و نوآوری نرم‌افزار",
      email: "a.h.razavi@aviژه-co.ir",
      phoneNumber: "۰۹۱۲-۳۴۵-۶۷۸۹",
      profileImageUrl: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode
        ? Colors.white12.withOpacity(0.15)
        : Colors.white;
    final headerBackgroundColor =
        isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F);
    final headerTextColor = Colors.white;
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF232428) : Colors.white;
    final primaryTextColor = isDarkMode
        ? Colors.white.withOpacity(0.9)
        : Colors.black.withOpacity(0.87);
    final secondaryTextColor = isDarkMode
        ? Colors.white.withOpacity(0.7)
        : Colors.black.withOpacity(0.65);
    final iconColor =
        isDarkMode ? Colors.white.withOpacity(0.75) : Colors.grey.shade700;
    final sectionTitleColor = isDarkMode
        ? Colors.white.withOpacity(0.85)
        : Colors.black.withOpacity(0.8);
    final accentColor = Colors.tealAccent.shade200;

    if (_pageIsLoading) {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? accentColor : Colors.teal.shade600),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileHeader(context, primaryTextColor,
                        secondaryTextColor, accentColor, isDarkMode),
                    SizedBox(height: 1.h),
                    _buildInfoSection(
                      context: context,
                      title: "اطلاعات سازمانی",
                      icon: Icons.business_center_outlined,
                      items: [
                        _InfoRowData(
                            icon: Icons.apartment_outlined,
                            label: "نام سازمان",
                            value: _userData.organizationName),
                        if (_userData.department != null &&
                            _userData.department!.isNotEmpty)
                          _InfoRowData(
                              icon: Icons.group_work_outlined,
                              label: "واحد/دپارتمان",
                              value: _userData.department!),
                        _InfoRowData(
                            icon: Icons.badge_outlined,
                            label: "سِمَت",
                            value: _userData.role),
                      ],
                      cardBackgroundColor: cardBackgroundColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      iconColor: iconColor,
                      sectionTitleColor: sectionTitleColor,
                      isDarkMode: isDarkMode,
                      animationDelay: 200.ms,
                    ),
                    _buildInfoSection(
                      context: context,
                      title: "اطلاعات تماس",
                      icon: Icons.contact_page_outlined,
                      items: [
                        _InfoRowData(
                            icon: Icons.email_outlined,
                            label: "آدرس ایمیل",
                            value: _userData.email),
                        if (_userData.phoneNumber != null &&
                            _userData.phoneNumber!.isNotEmpty)
                          _InfoRowData(
                              icon: Icons.phone_iphone_outlined,
                              label: "تلفن همراه",
                              value: _userData.phoneNumber!),
                      ],
                      cardBackgroundColor: cardBackgroundColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      iconColor: iconColor,
                      sectionTitleColor: sectionTitleColor,
                      isDarkMode: isDarkMode,
                      animationDelay: 300.ms,
                    ),
                    _buildInfoSection(
                      context: context,
                      title: "تنظیمات حساب",
                      icon: Icons.manage_accounts_outlined,
                      items: [
                        _InfoRowData(
                          icon: Icons.password_outlined,
                          label: "تغییر رمز عبور",
                          value: "",
                          isAction: true,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'عملکرد تغییر رمز عبور در نسخه‌های بعدی اضافه خواهد شد.',
                                    style: GoogleFonts.poppins()),
                                backgroundColor: Colors.blueGrey,
                              ),
                            );
                          },
                        ),
                        _InfoRowData(
                          icon: Icons.exit_to_app_outlined,
                          label: "خروج از حساب کاربری",
                          value: "",
                          isAction: true,
                          actionColor: isDarkMode
                              ? Colors.red.shade300
                              : Colors.red.shade700,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'کاربر گرامی، شما با موفقیت خارج شدید! (شبیه‌سازی)',
                                    style: GoogleFonts.poppins()),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ],
                      cardBackgroundColor: cardBackgroundColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      iconColor: iconColor,
                      sectionTitleColor: sectionTitleColor,
                      isDarkMode: isDarkMode,
                      animationDelay: 400.ms,
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildProfileHeader(BuildContext context, Color nameColor,
      Color roleColor, Color accentColor, bool isDarkMode) {
    String getInitials(String fullName) {
      List<String> names = fullName.split(" ");
      String initials = "";
      if (names.isNotEmpty) {
        initials += names[0].isNotEmpty ? names[0][0] : "";
        if (names.length > 1 && names.last.isNotEmpty) {
          initials += names.last[0];
        } else if (names[0].length > 1) {
          initials = names[0].substring(0, 1).toUpperCase();
        }
      }
      return initials.toUpperCase();
    }

    final avatarChild = _userData.profileImageUrl != null &&
            _userData.profileImageUrl!.isNotEmpty
        ? null
        : Text(
            getInitials(_userData.fullName),
            style: GoogleFonts.poppins(
                fontSize: 18.sp,
                color: isDarkMode ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.w600),
          );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
      margin: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2A2B2F)
            : Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 13.w,
            backgroundColor: _userData.profileImageUrl != null &&
                    _userData.profileImageUrl!.isNotEmpty
                ? Colors.transparent
                : (isDarkMode
                    ? accentColor.withOpacity(0.8)
                    : Theme.of(context).primaryColor.withOpacity(0.6)),
            backgroundImage: _userData.profileImageUrl != null &&
                    _userData.profileImageUrl!.isNotEmpty
                ? NetworkImage(_userData.profileImageUrl!)
                : null,
            child: avatarChild,
          )
              .animate()
              .scale(delay: 100.ms, duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: 2.h),
          Text(
            _userData.fullName,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 16.sp, fontWeight: FontWeight.bold, color: nameColor),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, duration: 300.ms),
          SizedBox(height: 0.5.h),
          Text(
            _userData.role,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: roleColor.withOpacity(isDarkMode ? 0.8 : 1.0),
                fontWeight: FontWeight.w500),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.3, duration: 300.ms),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.05, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<_InfoRowData> items,
    required Color cardBackgroundColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color iconColor,
    required Color sectionTitleColor,
    required bool isDarkMode,
    required Duration animationDelay,
  }) {
    return Card(
      elevation: isDarkMode ? 1.5 : 2.5,
      color: cardBackgroundColor,
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: sectionTitleColor, size: 6.w),
                SizedBox(width: 2.5.w),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: sectionTitleColor),
                ),
              ],
            ),
            Divider(
                height: 2.5.h,
                thickness: 0.5,
                color: (isDarkMode ? Colors.white : Colors.black)
                    .withOpacity(0.1)),
            ...items.asMap().entries.map((entry) {
              int idx = entry.key;
              _InfoRowData itemData = entry.value;
              return _InfoRow(
                data: itemData,
                isDarkMode: isDarkMode,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                iconColor: iconColor,
              ).animate(delay: (100 * idx).ms).fadeIn(duration: 300.ms).slideX(
                  begin: 0.1, duration: 250.ms, curve: Curves.easeOutSine);
            }).toList(),
          ],
        ),
      ),
    )
        .animate(delay: animationDelay)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, duration: 350.ms, curve: Curves.easeOutExpo);
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  final bool isAction;
  final Color? actionColor;
  final VoidCallback? onTap;

  _InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.isAction = false,
    this.actionColor,
    this.onTap,
  });
}

class _InfoRow extends StatelessWidget {
  final _InfoRowData data;
  final bool isDarkMode;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color iconColor;

  const _InfoRow({
    super.key,
    required this.data,
    required this.isDarkMode,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.isAction ? data.onTap : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.4.h, horizontal: 1.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(data.icon,
                color:
                    data.isAction ? (data.actionColor ?? iconColor) : iconColor,
                size: 5.5.w),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      color: data.isAction
                          ? (data.actionColor ?? primaryTextColor)
                          : secondaryTextColor,
                      fontWeight:
                          data.isAction ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (!data.isAction && data.value.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0.2.h),
                      child: Text(
                        data.value,
                        style: GoogleFonts.poppins(
                            fontSize: 12.5.sp,
                            color: primaryTextColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            if (data.isAction)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 4.w,
                  color:
                      data.actionColor ?? secondaryTextColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}
