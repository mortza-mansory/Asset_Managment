import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_size_text/auto_size_text.dart'; // گرچه شاید اینجا کمتر لازم باشد

// --- Data Model for User Profile ---
class UserProfileData {
  final String fullName;
  final String role;
  final String organizationName;
  final String? department; // Optional
  final String email;
  final String? phoneNumber; // Optional
  final String? profileImageUrl; // Optional, for network image

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

// --- User Profile Page Widget ---
class UserProfilePage extends StatefulWidget {
  final bool isDarkMode;

  const UserProfilePage({super.key, required this.isDarkMode});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _pageIsLoading = true;
  late UserProfileData _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load (or simulate loading) user data
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _pageIsLoading = false);
    });
  }

  void _loadUserData() {
    // In a real app, this would fetch data from a service or local storage
    _userData = UserProfileData(
      fullName: "جناب آقای سید امیرحسین رضوی", // نام کامل‌تر
      role: "مدیر ارشد سامانه هوشمند اموال",   // سِمَت دقیق‌تر
      organizationName: "شرکت دانش‌بنیان پرتو پردازشگران آویژه", // نام سازمان کامل
      department: "تیم توسعه و نوآوری نرم‌افزار",       // واحد سازمانی
      email: "a.h.razavi@aviژه-co.ir",       // ایمیل سازمانی
      phoneNumber: "۰۹۱۲-۳۴۵-۶۷۸۹",            // شماره تماس (مثال)
      profileImageUrl: null, // برای نمایش آواتار پیش‌فرض یا حرف اول نام
      // profileImageUrl: "https://avatars.githubusercontent.com/u/1234567?v=4", // آدرس تصویر نمونه
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF18191B) : const Color(0xFFF0F2F5);
    final appBarBackgroundColor = isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F);
    final headerTextColor = Colors.white; // For AppBar title
    final cardBackgroundColor = isDarkMode ? const Color(0xFF232428) : Colors.white; // کمی تیره‌تر از پس‌زمینه اصلی در حالت دارک
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.87);
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.65);
    final iconColor = isDarkMode ? Colors.white.withOpacity(0.75) : Colors.grey.shade700;
    final sectionTitleColor = isDarkMode ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.8);
    final accentColor = Colors.tealAccent.shade200; // برای آواتار و جداکننده‌ها


    if (_pageIsLoading) {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? accentColor : Colors.teal.shade600),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        elevation: isDarkMode ? 0.5 : 1.0,
        centerTitle: true,
        title: Text(
          'نمایه کاربری',
          style: GoogleFonts.poppins(fontSize: 16.5.sp, fontWeight: FontWeight.w600, color: headerTextColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: headerTextColor, size: 5.5.w),
          onPressed: () => context.go("/home"),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Profile Header ---
            _buildProfileHeader(context, primaryTextColor, secondaryTextColor, accentColor, isDarkMode),

            SizedBox(height: 1.h), // فاصله کمتر بعد از هدر

            // --- Sections ---
            _buildInfoSection(
              title: "اطلاعات سازمانی",
              icon: Icons.business_center_outlined,
              items: [
                _InfoRowData(icon: Icons.apartment_outlined, label: "نام سازمان", value: _userData.organizationName),
                if (_userData.department != null && _userData.department!.isNotEmpty)
                  _InfoRowData(icon: Icons.group_work_outlined, label: "واحد/دپارتمان", value: _userData.department!),
                _InfoRowData(icon: Icons.badge_outlined, label: "سِمَت", value: _userData.role),

              ],
              cardBackgroundColor: cardBackgroundColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              iconColor: iconColor,
              sectionTitleColor: sectionTitleColor,
              isDarkMode: isDarkMode,
              animationDelay: 200.ms,
              context: context
            ),

            _buildInfoSection(
              title: "اطلاعات تماس",
              icon: Icons.contact_page_outlined,
              items: [
                _InfoRowData(icon: Icons.email_outlined, label: "آدرس ایمیل", value: _userData.email),
                if (_userData.phoneNumber != null && _userData.phoneNumber!.isNotEmpty)
                  _InfoRowData(icon: Icons.phone_iphone_outlined, label: "تلفن همراه", value: _userData.phoneNumber!),
              ],
              cardBackgroundColor: cardBackgroundColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              iconColor: iconColor,
              sectionTitleColor: sectionTitleColor,
              isDarkMode: isDarkMode,
              animationDelay: 300.ms,
               context: context

            ),

            _buildInfoSection(
              title: "تنظیمات حساب",
              icon: Icons.manage_accounts_outlined, // آیکون مناسب‌تر
              items: [
                _InfoRowData(
                    icon: Icons.password_outlined,
                    label: "تغییر رمز عبور",
                    value: "", // مقدار خالی چون عملیاتی است
                    isAction: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('عملکرد تغییر رمز عبور در نسخه‌های بعدی اضافه خواهد شد.', style: GoogleFonts.poppins()), backgroundColor: Colors.blueGrey),
                      );
                    }
                ),
                _InfoRowData(
                    icon: Icons.exit_to_app_outlined,
                    label: "خروج از حساب کاربری",
                    value: "",
                    isAction: true,
                    actionColor: isDarkMode ? Colors.red.shade300 : Colors.red.shade700, // رنگ متمایز برای خروج
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('کاربر گرامی، شما با موفقیت خارج شدید! (شبیه‌سازی)', style: GoogleFonts.poppins()), backgroundColor: Colors.green),
                      );
                    }
                ),
              ],
              cardBackgroundColor: cardBackgroundColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              iconColor: iconColor,
              sectionTitleColor: sectionTitleColor,
              isDarkMode: isDarkMode,
              animationDelay: 400.ms,
              context: context

            ),
            SizedBox(height: 3.h), // فضای خالی در انتهای صفحه
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildProfileHeader(BuildContext context, Color nameColor, Color roleColor, Color accentColor, bool isDarkMode) {
    String getInitials(String fullName) {
      List<String> names = fullName.split(" ");
      String initials = "";
      if (names.isNotEmpty) {
        initials += names[0].isNotEmpty ? names[0][0] : "";
        if (names.length > 1 && names.last.isNotEmpty) {
          initials += names.last[0];
        } else if (names[0].length > 1) {
          initials = names[0].substring(0,1).toUpperCase(); // اگر فقط یک کلمه بود و طولانی
        }
      }
      return initials.toUpperCase();
    }

    final avatarChild = _userData.profileImageUrl != null && _userData.profileImageUrl!.isNotEmpty
        ? null // NetworkImage will be background
        : Text(
      getInitials(_userData.fullName),
      style: GoogleFonts.poppins(fontSize: 18.sp, color: isDarkMode? Colors.black87 : Colors.white, fontWeight: FontWeight.w600),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
      margin: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2B2F) : Theme.of(context).primaryColor.withOpacity(0.05), // رنگ پس‌زمینه هدر
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: isDarkMode ? null : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0,4),
            )
          ]
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 13.w, // بزرگتر
            backgroundColor: _userData.profileImageUrl != null && _userData.profileImageUrl!.isNotEmpty
                ? Colors.transparent // اگر تصویر داریم، پس زمینه شفاف
                : (isDarkMode ? accentColor.withOpacity(0.8) : Theme.of(context).primaryColor.withOpacity(0.6)),
            backgroundImage: _userData.profileImageUrl != null && _userData.profileImageUrl!.isNotEmpty
                ? NetworkImage(_userData.profileImageUrl!) // Load image from network
                : null, // No background image if initials are shown
            child: avatarChild,
          ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(height: 2.h),
          Text(
            _userData.fullName,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: nameColor),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, duration: 300.ms),
          SizedBox(height: 0.5.h),
          Text(
            _userData.role,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: roleColor.withOpacity(isDarkMode ? 0.8 : 1.0), fontWeight: FontWeight.w500),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.3, duration: 300.ms),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05, duration: 300.ms, curve: Curves.easeOut);
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
                  style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: sectionTitleColor),
                ),
              ],
            ),
            Divider(height: 2.5.h, thickness: 0.5, color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1)),
            ...items.asMap().entries.map((entry) {
              int idx = entry.key;
              _InfoRowData itemData = entry.value;
              return _InfoRow(
                data: itemData,
                isDarkMode: isDarkMode,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                iconColor: iconColor,
              ).animate(delay: (100 * idx).ms) // انیمیشن برای هر ردیف با تاخیر
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.1, duration: 250.ms, curve: Curves.easeOutSine);
            }).toList(),
          ],
        ),
      ),
    ).animate(delay: animationDelay)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, duration: 350.ms, curve: Curves.easeOutExpo);
  }
}

// --- Helper class for _InfoRow data ---
class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  final bool isAction;
  final Color? actionColor; // For action items like logout
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

// --- Reusable widget for displaying a single piece of info ---
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
    return InkWell( // برای اینکه کل ردیف قابل کلیک باشد اگر isAction true است
      onTap: data.isAction ? data.onTap : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.4.h, horizontal: 1.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(data.icon, color: data.isAction ? (data.actionColor ?? iconColor) : iconColor, size: 5.5.w),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Column( // استفاده از Column برای چیدمان بهتر لیبل و مقدار در صورت نیاز در آینده
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      color: data.isAction ? (data.actionColor ?? primaryTextColor) : secondaryTextColor,
                      fontWeight: data.isAction ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (!data.isAction && data.value.isNotEmpty) // نمایش مقدار فقط اگر عملیاتی نیست
                    Padding(
                      padding: EdgeInsets.only(top: 0.2.h),
                      child: Text(
                        data.value,
                        style: GoogleFonts.poppins(fontSize: 12.5.sp, color: primaryTextColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            if (data.isAction)
              Icon(Icons.arrow_forward_ios_rounded, size: 4.w, color: data.actionColor ?? secondaryTextColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}
