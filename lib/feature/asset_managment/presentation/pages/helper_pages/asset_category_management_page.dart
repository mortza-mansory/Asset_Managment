// assetsrfid/lib/feature/asset_managment/presentation/pages/asset_category_management_page.dart

import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Import AssetCategoryEntity (from domain layer, will use real data later)
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';

class AssetCategoryManagementPage extends StatefulWidget {
  const AssetCategoryManagementPage({super.key});

  @override
  State<AssetCategoryManagementPage> createState() => _AssetCategoryManagementPageState();
}

class _AssetCategoryManagementPageState extends State<AssetCategoryManagementPage> {
  // Dummy data for categories (will be replaced by Bloc state)
  List<AssetCategoryEntity> _categories = [];

  // Helper to convert hex string to Color object
  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor; // Add FF for opacity
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // Helper to convert icon name string to IconData (from AssetCategoryEntity's icon getter)
  IconData _iconFromName(String iconName) {
    switch (iconName) {
      case 'laptop_mac_outlined': return Icons.laptop_mac_outlined;
      case 'chair_outlined': return Icons.chair_outlined;
      case 'build_outlined': return Icons.build_outlined;
      case 'directions_car_outlined': return Icons.directions_car_outlined;
      case 'storage_outlined': return Icons.storage_outlined;
      case 'router_outlined': return Icons.router_outlined;
      case 'science_outlined': return Icons.science_outlined;
      default: return Icons.category_outlined; // Default fallback
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDummyCategories(); // Load dummy data
  }

  void _loadDummyCategories() {
    _categories = [
      AssetCategoryEntity(id: 1, name: 'تجهیزات الکترونیکی', code: 101, iconName: 'laptop_mac_outlined', colorHex: '#42A5F5'),
      AssetCategoryEntity(id: 2, name: 'مبلمان اداری', code: 102, iconName: 'chair_outlined', colorHex: '#66BB6A'),
      AssetCategoryEntity(id: 3, name: 'ابزارآلات صنعتی', code: 103, iconName: 'build_outlined', colorHex: '#FFA726'),
      AssetCategoryEntity(id: 4, name: 'وسایل نقلیه', code: 104, iconName: 'directions_car_outlined', colorHex: '#EF5350'),
      AssetCategoryEntity(id: 5, name: 'لوازم دفتری', code: 105, iconName: 'storage_outlined', colorHex: '#AB47BC'),
      AssetCategoryEntity(id: 6, name: 'تجهیزات شبکه', code: 106, iconName: 'router_outlined', colorHex: '#26C6DA'),
      AssetCategoryEntity(id: 7, name: 'تجهیزات آزمایشگاهی', code: 107, iconName: 'science_outlined', colorHex: '#7E57C2'),
    ];
  }

  void _showEditCategoryDialog(BuildContext context, AssetCategoryEntity category) {
    final l10n = context.l10n;
    final TextEditingController nameController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.categoryEditTitle(category.name)),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.categoryNameLabel,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancelButton),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Dispatch UpdateCategoryName event to Bloc
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.categoryUpdateSuccess(nameController.text))),
                );
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? Colors.white12.withOpacity(0.15) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.categoryManagementTitle, style: GoogleFonts.poppins()),
        backgroundColor: isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F),
        foregroundColor: primaryTextColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final categoryColor = category.color ?? Colors.blueGrey; // Use entity's color getter
                final categoryIcon = category.icon ?? Icons.category_outlined; // Use entity's icon getter

                return Card(
                  color: cardColor,
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 0.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: categoryColor.withOpacity(0.5), width: 1),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 5.w,
                          backgroundColor: categoryColor.withOpacity(0.1),
                          child: Icon(categoryIcon, color: categoryColor, size: 6.w),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // SizedBox(height: 0.5.h),
                              // Text(
                              //   '${l10n.categoryCode}: ${category.code}',
                              //   style: GoogleFonts.poppins(fontSize: 10.sp, color: secondaryTextColor),
                              // ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: secondaryTextColor),
                          onPressed: () => _showEditCategoryDialog(context, category),
                          tooltip: l10n.categoryEditTooltip,
                        ),
                        // TODO: Add delete icon button with confirmation dialog
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
              },
            ),
          ),
          // Support message
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              l10n.categoryManagementSupportMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 10.sp, color: secondaryTextColor),
            ).animate().fadeIn(delay: 500.ms),
          ),
        ],
      ),
    );
  }
}