import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavItem {
  final IconData icon;
  final String text;
  final String tooltip;

  const NavItem({
    required this.icon,
    required this.text,
    required this.tooltip,
  });
}

class CustomFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final List<NavItem> items = const [
    NavItem(icon: Icons.home_filled, text: 'خانه', tooltip: 'صفحه اصلی'),
    NavItem(
        icon: Icons.document_scanner_outlined,
        text: 'RFID اسکن',
        tooltip: 'اسکن RFID'),
    NavItem(icon: Icons.search, text: 'جستجو', tooltip: 'جستجوی دارایی‌ها'),
    NavItem(
        icon: Icons.account_circle_outlined,
        text: 'حساب',
        tooltip: 'تنظیمات کاربری'),
  ];

  double _getExpandedWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 380) return screenWidth * 0.35;
    if (screenWidth <= 450) return screenWidth * 0.32;
    return screenWidth * 0.28;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;

    final navBarBackgroundColor =
        isDarkMode ? const Color(0xFF2C2C2E) : Colors.white;

    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.06)
        : Colors.grey.withOpacity(0.3);

    final unselectedItemColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    double iconOnlyWidth = 15.w > 60 ? 60 : 15.w;
    double expandedWidth = _getExpandedWidth(context);
    double navBarHeight = 6.h > 20 ? 6.h : 25;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
      child: Container(
        height: navBarHeight,
        decoration: BoxDecoration(
          color: navBarBackgroundColor,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCirc,
                width: isSelected ? expandedWidth : iconOnlyWidth,
                height: navBarHeight * 0.75,
                padding: EdgeInsets.symmetric(horizontal: isSelected ? 3.w : 0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDarkMode
                          ? Colors.blueGrey.withOpacity(0.6)
                          : const Color(0xFF455A64))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? Colors.white : unselectedItemColor,
                      size: isSelected ? 6.5.w : 6.w,
                    ),
                    if (isSelected) SizedBox(width: 2.w),
                    if (isSelected)
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: AutoSizeText(
                            item.text,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
