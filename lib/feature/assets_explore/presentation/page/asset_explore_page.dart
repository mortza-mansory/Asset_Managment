// assetsrfid/lib/feature/asset_managment/presentation/pages/asset_explore_page.dart

import 'dart:async';
import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/bloc/assets_explore/asset_explore_bloc.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/bloc/assets_explore/asset_explore_event.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/bloc/assets_explore/asset_explore_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:get_it/get_it.dart';

import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart';

// Helper to get localized status based on AssetStatus enum
String _localizedAssetStatus(AssetStatus status, AppLocalizations l10n) {
  switch (status) {
    case AssetStatus.active:
      return l10n.assetStatusActive;
    case AssetStatus.inactive:
      return l10n.assetStatusInactive;
    case AssetStatus.maintenance:
      return l10n.assetStatusMaintenance;
    case AssetStatus.disposed:
      return l10n.assetStatusDisposed;
    case AssetStatus.on_loan:
      return l10n.assetStatusOnLoan;
    default:
      return status.name;
  }
}

// Helper to get status color based on AssetStatus enum
Color _getStatusColor(AssetStatus status) {
  switch (status) {
    case AssetStatus.active:
      return Colors.green.shade400;
    case AssetStatus.inactive:
      return Colors.red.shade400;
    case AssetStatus.maintenance:
      return Colors.orange.shade400;
    case AssetStatus.disposed:
      return Colors.grey;
    case AssetStatus.on_loan:
      return Colors.blue.shade400;
    default:
      return Colors.grey;
  }
}
// --- End UI Helper Functions ---

enum AssetDisplayMode { rectangular, square }

class AssetExplorePage extends StatefulWidget {
  const AssetExplorePage({super.key});

  @override
  State<AssetExplorePage> createState() => _AssetExplorePageState();
}

class _AssetExplorePageState extends State<AssetExplorePage> {
  // Search state
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  Timer? _debounce;

  // Filter state
  int? _selectedCategoryId; // Null for "All"

  // Display mode state
  AssetDisplayMode _displayMode = AssetDisplayMode.rectangular;

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch event
    _fetchAssetsAndCategories(isInitialFetch: true);

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (_searchText != _searchController.text) {
          setState(() {
            _searchText = _searchController.text;
            _fetchAssetsAndCategories(); // Trigger fetch with search query
          });
        }
      });
    });
  }

  void _fetchAssetsAndCategories({bool isInitialFetch = false}) {
    final sessionService = GetIt.instance<SessionService>();
    final activeCompany = sessionService.getActiveCompany();

    if (activeCompany != null) {
      context.read<AssetExploreBloc>().add(
        FetchAssetsAndCategories(
          companyId: activeCompany.id,
          searchQuery: _searchText.isNotEmpty ? _searchText : null,
          categoryId: _selectedCategoryId == 0 ? null : _selectedCategoryId, // 0 for "All" means no category filter
          isInitialFetch: isInitialFetch,
        ),
      );
    } else {
      // Handle case where no active company is selected, maybe show an error or redirect
      // For now, the Bloc will handle "No active company selected" failure.
    }
  }

  void _onCategorySelected(int categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _fetchAssetsAndCategories(); // Trigger fetch with new category filter
    });
  }

  void _toggleDisplayMode() {
    setState(() {
      _displayMode = (_displayMode == AssetDisplayMode.rectangular)
          ? AssetDisplayMode.square
          : AssetDisplayMode.rectangular;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchText = "";
      _fetchAssetsAndCategories(); // Trigger fetch to clear search results
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor =
    isDarkMode ? Colors.white12.withOpacity(0.15) : Colors.white;
    final hintTextColor =
    isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final iconColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    final textFieldFillColor = isDarkMode
        ? Colors.black.withOpacity(0.15)
        : Colors.white; // Changed to white for better contrast in light mode
    final filterChipBackgroundColor =
    isDarkMode ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
    final filterChipSelectedColor =
    isDarkMode ? Colors.teal.shade700 : Colors.teal.shade400;
    final filterChipTextColor =
    isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black87;
    final filterChipSelectedTextColor = Colors.white;
    final appBarSurfaceColor =
    isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Area
            Container(
              color: appBarSurfaceColor,
              padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.5.h),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: l10n.searchPageHintText,
                  hintStyle:
                  GoogleFonts.poppins(fontSize: 12.sp, color: hintTextColor),
                  filled: true,
                  fillColor: textFieldFillColor,
                  prefixIcon:
                  Icon(Icons.search_rounded, color: iconColor, size: 6.w),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear_rounded,
                        color: iconColor, size: 5.5.w),
                    onPressed: _clearSearch,
                  )
                      : null,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.grey.shade700.withOpacity(0.7)
                            : Colors.grey.shade300,
                        width: 0.8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.tealAccent.shade100
                            : Colors.teal.shade400,
                        width: 1.5),
                  ),
                ),
                onSubmitted: (value) => _fetchAssetsAndCategories(),
              ),
            ),
            // Category Filters Rail
            BlocBuilder<AssetExploreBloc, AssetExploreState>(
              buildWhen: (previous, current) =>
              previous is! AssetExploreLoaded || current is AssetExploreLoaded || (current is AssetExploreLoading),
              builder: (context, state) {
                List<AssetCategoryEntity> categories = [];
                if (state is AssetExploreLoaded) {
                  categories = state.categories;
                  if (_selectedCategoryId == null && categories.isNotEmpty) {
                    _selectedCategoryId = categories.first.id;
                  } else if (!categories.any((cat) => cat.id == _selectedCategoryId!) && categories.isNotEmpty) {
                    _selectedCategoryId = categories.first.id;
                  }
                } else if (state is AssetExploreLoading) {
                  final previousState = context.read<AssetExploreBloc>().state;
                  if (previousState is AssetExploreLoaded) {
                    categories = previousState.categories;
                  }
                  if (state.isInitialLoad) {
                    return _buildCategoryShimmer(filterChipBackgroundColor, filterChipSelectedColor, filterChipTextColor, filterChipSelectedTextColor, isDarkMode);
                  }
                }

                if (categories.isEmpty && (state is! AssetExploreLoading || (state is AssetExploreLoading && !state.isInitialLoad))) {
                  return const SizedBox.shrink();
                }

                return Container(
                  color: appBarSurfaceColor,
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: SizedBox(
                    height: 4.5.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = _selectedCategoryId == category.id;
                        final isAllCategory = category.id == 0; // Check for "All" category

                        return Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: GestureDetector(
                            onTap: () => _onCategorySelected(category.id),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.5.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? filterChipSelectedColor
                                    : (category.color ?? filterChipBackgroundColor),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: isSelected
                                      ? filterChipSelectedColor
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (category.icon != null)
                                      Icon(
                                        category.icon,
                                        size: 4.w,
                                        color: isSelected
                                            ? filterChipSelectedTextColor
                                            : (category.color != null ? Colors.white : filterChipTextColor),
                                      ),
                                    if (category.icon != null)
                                      SizedBox(width: 1.5.w),
                                    Text(
                                      category.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.sp,
                                        color: isSelected
                                            ? filterChipSelectedTextColor
                                            : filterChipTextColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (isAllCategory) // Add the management button next to "All"
                                      Padding(
                                        padding: EdgeInsets.only(left: 1.5.w),
                                        child: GestureDetector(
                                          onTap: () {
                                            context.push('/asset_category_management'); // Navigate to new page
                                          },
                                          child: Icon(Icons.settings_outlined, size: 4.5.w, color: isSelected ? filterChipSelectedTextColor : filterChipTextColor),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            // Main Content with floating toggle
            Expanded(
              child: Stack(
                children: [
                  BlocBuilder<AssetExploreBloc, AssetExploreState>(
                    builder: (context, state) {
                      List<AssetEntity> assetsToDisplay = [];
                      String? currentSearchQuery = _searchText;
                      bool isFilteringLoading = false; // Indicates loading for filter/search, not initial load
                      Map<int, AssetCategoryEntity> categoryMap = {}; // Map for easy category lookup

                      if (state is AssetExploreLoaded) {
                        assetsToDisplay = state.assets;
                        currentSearchQuery = state.currentSearchQuery;
                        // Populate categoryMap for children widgets
                        for (var cat in state.categories) {
                          categoryMap[cat.id] = cat;
                        }
                      } else if (state is AssetExploreLoading) {
                        if (state.isInitialLoad) {
                          // Show full screen initial loading
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade600),
                            ),
                          );
                        } else {
                          // This is a filter/search loading, try to show previous data with loader overlay
                          isFilteringLoading = true;
                          final previousState = context.read<AssetExploreBloc>().state;
                          if (previousState is AssetExploreLoaded) {
                            assetsToDisplay = previousState.assets; // Show old assets
                            currentSearchQuery = previousState.currentSearchQuery;
                            for (var cat in previousState.categories) {
                              categoryMap[cat.id] = cat;
                            }
                          }
                        }
                      } else if (state is AssetExploreFailure) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 20.w, color: Colors.red.shade400),
                              SizedBox(height: 2.h),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 12.sp, color: Colors.red.shade400),
                              ),
                              SizedBox(height: 2.h),
                              ElevatedButton(
                                onPressed: () => _fetchAssetsAndCategories(isInitialFetch: true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                child: Text(l10n.tryAgain, style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      }

                      // Pass categoryMap to asset item cards
                      return _buildAssetList(l10n, isDarkMode, assetsToDisplay, currentSearchQuery, isFilteringLoading, categoryMap);
                    },
                  ),
                  Positioned(
                    top: 1.h,
                    right: 4.w,
                    child: _buildDisplayModeToggle(
                        filterChipBackgroundColor,
                        filterChipSelectedColor,
                        filterChipSelectedTextColor,
                        filterChipTextColor,
                        isDarkMode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => context.push('/asset_add'),
      //   backgroundColor: Colors.teal,
      //   tooltip: l10n.assetAddAsset,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  Widget _buildAssetList(AppLocalizations l10n, bool isDarkMode, List<AssetEntity> assets, String? currentSearchQuery, bool isFilteringLoading, Map<int, AssetCategoryEntity> categoryMap) {
    if (isFilteringLoading && assets.isEmpty) { // Show loading only if no assets to display yet
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade600),
            ),
            SizedBox(height: 2.h),
            Text(
              currentSearchQuery != null && currentSearchQuery.isNotEmpty
                  ? l10n.searchStatusSearchingFor(currentSearchQuery)
                  : l10n.loadingData,
              style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.65)
                      : Colors.black.withOpacity(0.65)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }
    // If isFilteringLoading is true but assets is not empty, it means we show old data.
    // In this case, we would usually show a small loader on top of the list, not full screen.
    // For now, this logic assumes full screen loader if no assets, otherwise list.

    if (assets.isEmpty && !isFilteringLoading) { // Only show empty state if not loading and empty
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 20.w,
                color: isDarkMode
                    ? Colors.blueGrey.shade200
                    : Colors.blueGrey.shade500),
            SizedBox(height: 2.h),
            Text(
              currentSearchQuery != null && currentSearchQuery.isNotEmpty
                  ? l10n.searchEmptyStateNotFound(currentSearchQuery)
                  : l10n.emptyAssetState,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.65)
                      : Colors.black.withOpacity(0.65),
                  height: 1.5),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    if (_displayMode == AssetDisplayMode.rectangular) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        itemCount: assets.length,
        itemBuilder: (context, itemIndex) {
          return _AssetListItemCard(asset: assets[itemIndex], l10n: l10n, categoryMap: categoryMap)
              .animate()
              .fadeIn(delay: (100 * itemIndex).ms, duration: 400.ms)
              .slideX(begin: 0.2, curve: Curves.easeOut);
        },
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 3.w,
          childAspectRatio: 0.9,
        ),
        itemCount: assets.length,
        itemBuilder: (context, itemIndex) {
          return _AssetGridItemCard(asset: assets[itemIndex], l10n: l10n, categoryMap: categoryMap)
              .animate()
              .fadeIn(delay: (100 * itemIndex).ms, duration: 400.ms)
              .scale(begin: Offset(0.9, 0.9), curve: Curves.easeOut);
        },
      );
    }
  }

  Widget _buildDisplayModeToggle(Color bgColor, Color selectedColor,
      Color selectedTextColor, Color textColor, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ToggleButtons(
        isSelected: [
          _displayMode == AssetDisplayMode.rectangular,
          _displayMode == AssetDisplayMode.square,
        ],
        onPressed: (int index) {
          _toggleDisplayMode();
        },
        renderBorder: false,
        fillColor: selectedColor,
        selectedColor: selectedTextColor,
        color: textColor,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
            child: Icon(Icons.view_agenda_outlined, size: 4.5.w),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
            child: Icon(Icons.grid_view_outlined, size: 4.5.w),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryShimmer(Color bgColor, Color selectedColor, Color textColor, Color selectedTextColor, bool isDarkMode) {
    return Container(
      color: isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F),
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: SizedBox(
        height: 4.5.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: 4, // Show a few shimmer items
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: Container(
                width: 20.w, // Shimmer width
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(duration: 1200.ms, color: Colors.white12),
            );
          },
        ),
      ),
    );
  }
}

// In _AssetListItemCard
class _AssetListItemCard extends StatelessWidget {
  final AssetEntity asset;
  final AppLocalizations l10n;
  final Map<int, AssetCategoryEntity> categoryMap;

  const _AssetListItemCard({
    required this.asset,
    required this.l10n,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;

    final statusColor = _getStatusColor(asset.status);
    final localizedStatus = _localizedAssetStatus(asset.status, l10n);

    IconData assetIcon = Icons.inventory_2_outlined;
    Color assetIconColor = statusColor;

    final category = categoryMap[asset.categoryId];
    if (category != null) {
      if (category.icon != null) {
        assetIcon = category.icon!;
      }
      if (category.color != null) {
        assetIconColor = category.color!;
      }
    }

    return Card(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () => context.push('/asset_detail/${asset.rfidTag}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 6.w,
                backgroundColor: statusColor.withOpacity(0.1),
                child: Icon(assetIcon, color: assetIconColor, size: 7.w),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      asset.assetId,
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
                  localizedStatus,
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// In _AssetGridItemCard
class _AssetGridItemCard extends StatelessWidget {
  final AssetEntity asset;
  final AppLocalizations l10n;
  final Map<int, AssetCategoryEntity> categoryMap;

  const _AssetGridItemCard({
    required this.asset,
    required this.l10n,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;

    final statusColor = _getStatusColor(asset.status);
    final localizedStatus = _localizedAssetStatus(asset.status, l10n);

    IconData assetIcon = Icons.inventory_2_outlined;
    Color assetIconColor = statusColor;

    final category = categoryMap[asset.categoryId];
    if (category != null) {
      if (category.icon != null) {
        assetIcon = category.icon!;
      }
      if (category.color != null) {
        assetIconColor = category.color!;
      }
    }

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () => context.push('/asset_detail/${asset.rfidTag}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 7.w,
                backgroundColor: statusColor.withOpacity(0.1),
                child: Icon(assetIcon, color: assetIconColor, size: 8.w),
              ),
              SizedBox(height: 0.8.h),
              Text(
                asset.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.3.h),
              Text(
                asset.assetId,
                style: GoogleFonts.poppins(fontSize: 9.sp, color: secondaryTextColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  localizedStatus,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 8.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}