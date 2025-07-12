import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';

class NavItem {
  final IconData icon;
  final String label;
  final String tooltip;

  const NavItem({
    required this.icon,
    required this.label,
    required this.tooltip,
  });
}

class CustomFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;
  final bool canHide;
  final double navBarHeight;

  const CustomFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.canHide = false,
    required this.navBarHeight,
  });

  double _buildWidthExpansion(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth <= 380) return screenWidth * 59 / 100;
    if (screenWidth <= 450) return screenWidth * 47 / 50;
    return screenWidth * 7 / 25;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;

    final List<NavItem> items = [
      NavItem(
          icon: Icons.home_filled,
          label: l10n.navHome,
          tooltip: l10n.navHomeTooltip),
      NavItem(
          icon: Icons.document_scanner_outlined,
          label: l10n.navScan,
          tooltip: l10n.navScanTooltip),
      NavItem(
          icon: Icons.assessment_sharp,
          label: l10n.navAssetList,
          tooltip: l10n.navScanTooltip),
      NavItem(
          icon: Icons.receipt_long,
          label: l10n.loan,
          tooltip: l10n.loan),
      NavItem(
          icon: Icons.person,
          label: l10n.navProfile,
          tooltip: l10n.navProfileTooltip),
    ];

    final navBarBackgroundColor =
    isDarkMode ? const Color(0xFF2C2C2E) : Colors.white;
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.06)
        : Colors.grey.withOpacity(0.3);
    final unselectedItemColor =
    isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    double iconOnlyWidth = 15.w > 60 ? 60 : 15.w;
    double expandedWidth = _buildWidthExpansion(context);

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
              behavior: HitTestBehavior.opaque,
              child: Tooltip(
                message: item.tooltip,
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
                              item.label,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              key: Key('nav_item_label_$index'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}