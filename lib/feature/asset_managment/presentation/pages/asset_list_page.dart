import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';

class Asset {
  final String id;
  final String name;
  final String code;
  final String category;
  final String status;
  final IconData icon;

  Asset({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.status,
    required this.icon,
  });
}

class AssetListPage extends StatefulWidget {
  const AssetListPage({super.key});

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _tabs;
  late List<Asset> _allAssets;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.l10n;
    _tabs = [
      l10n.tabAll,
      l10n.tabElectronics,
      l10n.tabFurniture,
      l10n.tabTools,
    ];
    _tabController = TabController(length: _tabs.length, vsync: this);

    _allAssets = [
      Asset(id: '1', name: 'لپ‌تاپ Dell XPS 15', code: 'LP-00125', category: l10n.tabElectronics, status: l10n.assetStatusActive, icon: Icons.laptop_mac_outlined),
      Asset(id: '2', name: 'صندلی مدیریتی ارگونومیک', code: 'CH-0078', category: l10n.tabFurniture, status: l10n.assetStatusActive, icon: Icons.chair_outlined),
      Asset(id: '3', name: 'دریل شارژی Bosch', code: 'T-0158', category: l10n.tabTools, status: 'در تعمیر', icon: Icons.build_outlined),
      Asset(id: '4', name: 'مانیتور Samsung G7', code: 'MN-0098', category: l10n.tabElectronics, status: l10n.assetStatusMissing, icon: Icons.desktop_windows_outlined),
      Asset(id: '5', name: 'میز کنفرانس ۱۲ نفره', code: 'TBL-0012', category: l10n.tabFurniture, status: l10n.assetStatusActive, icon: Icons.table_restaurant_outlined),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Asset> _getAssetsForTab(int index) {
    if (index == 0) {
      return _allAssets;
    }
    final category = _tabs[index];
    return _allAssets.where((asset) => asset.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.white;
    final headerTextColor = isDarkMode ? Colors.white : Colors.black45;
    final appBarBackgroundColor = isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F);
    final scaffoldBackgroundColor =
    isDarkMode ? Colors.white12.withOpacity(0.15) : Colors.white;
    return Scaffold(
      backgroundColor:scaffoldBackgroundColor ,
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        foregroundColor: primaryTextColor,
        shadowColor: appBarBackgroundColor,
        surfaceTintColor:appBarBackgroundColor ,
        elevation: 1,
        // title: Text(
        //   l10n.assetListPageTitle,
        //   style: GoogleFonts.poppins(),
        // ),
        // actions: [],
        bottom: PreferredSize(
          preferredSize:  Size(1.w, 1.w),
          child: Container(
            color: appBarBackgroundColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: primaryTextColor,
              indicatorColor: primaryTextColor,
              unselectedLabelColor: primaryTextColor,

              tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tabs.length, (index) {
          final assets = _getAssetsForTab(index);
          if (assets.isEmpty) {
            return Center(
              child: Text(l10n.emptyAssetState, style: GoogleFonts.poppins()),
            ).animate().fadeIn();
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            itemCount: assets.length,
            itemBuilder: (context, itemIndex) {
              return _AssetListItemCard(asset: assets[itemIndex])
                  .animate()
                  .fadeIn(delay: (100 * itemIndex).ms, duration: 400.ms)
                  .slideX(begin: 0.2, curve: Curves.easeOut);
            },
          );
        }),
      ),
    );
  }
}

class _AssetListItemCard extends StatelessWidget {
  final Asset asset;
  const _AssetListItemCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;

    Map<String, Color> statusColors = {
      l10n.assetStatusActive: Colors.green.shade400,
      l10n.assetStatusMissing: Colors.red.shade400,
      'در تعمیر': Colors.orange.shade400,
    };
    final statusColor = statusColors[asset.status] ?? Colors.grey;

    return Card(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: statusColor.withOpacity(0.5), width: 1)
      ),
      child: InkWell(
        onTap: () => context.push('/asset_detail'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 6.w,
                backgroundColor: statusColor.withOpacity(0.1),
                child: Icon(asset.icon, color: statusColor, size: 7.w),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      asset.code,
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  asset.status,
                  style: GoogleFonts.poppins(fontSize: 9.sp, color: statusColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}