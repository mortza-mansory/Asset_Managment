
import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/bloc/asset_category_management/asset_category_management_bloc.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/bloc/asset_category_management/asset_category_management_event.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/bloc/asset_category_management/asset_category_management_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:get_it/get_it.dart';


Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active': return Colors.green.shade400;
    case 'inactive': return Colors.red.shade400;
    case 'maintenance': return Colors.orange.shade400;
    case 'disposed': return Colors.grey;
    case 'on_loan': return Colors.blue.shade400;
    default: return Colors.grey;
  }
}

class AssetCategoryManagementPage extends StatefulWidget {
  const AssetCategoryManagementPage({super.key});

  @override
  State<AssetCategoryManagementPage> createState() => _AssetCategoryManagementPageState();
}

class _AssetCategoryManagementPageState extends State<AssetCategoryManagementPage> {
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _categoryCodeController = TextEditingController();
  final TextEditingController _categoryDescriptionController = TextEditingController();
  final TextEditingController _assetSearchController = TextEditingController();

  AssetCategoryEntity? _categoryToEdit;
  List<int> _selectedAssetsForRemoval = []; // For removing assets from a category
  List<int> _selectedAssetsForAdding = []; // For adding assets to a category

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _assetSearchController.addListener(() {
      // Debounce logic for search can be added here if needed, similar to asset_explore_page
      if (_assetSearchController.text.isEmpty || _assetSearchController.text.length > 2) {
        _searchAssetsForLinking();
      }
    });
  }

  void _loadInitialData() {
    final companyId = GetIt.instance<SessionService>().getActiveCompany()?.id;
    if (companyId != null) {
      context.read<AssetCategoryManagementBloc>().add(LoadCategoriesAndAssets(companyId: companyId));
    }
  }

  void _searchAssetsForLinking() {
    final companyId = GetIt.instance<SessionService>().getActiveCompany()?.id;
    if (companyId != null) {
      context.read<AssetCategoryManagementBloc>().add(
        LoadAssetsForLinking(companyId: companyId, searchQuery: _assetSearchController.text),
      );
    }
  }

  void _showCategoryFormDialog({AssetCategoryEntity? category}) {
    _categoryToEdit = category;
    _categoryNameController.text = category?.name ?? '';
    _categoryCodeController.text = category?.code.toString() ?? '';
    _categoryDescriptionController.text = category?.description ?? '';
    // Icon and Color selection can be added here if you have a picker UI

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category == null ? 'Create New Category' : 'Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _categoryNameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                TextField(
                  controller: _categoryCodeController,
                  decoration: const InputDecoration(labelText: 'Category Code'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _categoryDescriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                // TODO: Add fields for Icon and Color selection using custom pickers
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final companyId = GetIt.instance<SessionService>().getActiveCompany()?.id;
                if (companyId == null) return;

                if (category == null) {
                  context.read<AssetCategoryManagementBloc>().add(
                    CreateCategory(
                      companyId: companyId,
                      name: _categoryNameController.text,
                      code: int.tryParse(_categoryCodeController.text) ?? 0,
                      description: _categoryDescriptionController.text.isNotEmpty ? _categoryDescriptionController.text : null,
                      // TODO: Pass selected icon and color
                    ),
                  );
                } else {
                  context.read<AssetCategoryManagementBloc>().add(
                    UpdateCategory(
                      categoryId: category.id!,
                      companyId: companyId,
                      name: _categoryNameController.text,
                      code: int.tryParse(_categoryCodeController.text) ?? category.code,
                      description: _categoryDescriptionController.text,
                      // TODO: Pass selected icon and color
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text(category == null ? 'Create' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int categoryId, int companyId, String categoryName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete category "$categoryName"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AssetCategoryManagementBloc>().add(
                  DeleteCategory(categoryId: categoryId, companyId: companyId),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAssetLinkingDialog(AssetCategoryEntity category) {
    _selectedAssetsForAdding.clear(); // Clear previous selections
    _assetSearchController.clear();
    final companyId = GetIt.instance<SessionService>().getActiveCompany()?.id;
    if (companyId != null) {
      context.read<AssetCategoryManagementBloc>().add(LoadAssetsForLinking(companyId: companyId));
    }

    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<AssetCategoryManagementBloc, AssetCategoryManagementState>(
          builder: (context, state) {
            List<AssetEntity> selectableAssets = [];
            List<int> currentSelected = [];
            bool isLoadingAssets = false;

            if (state is AssetLinkingSelectionState) {
              selectableAssets = state.selectableAssets;
              currentSelected = state.currentSelectedAssetIds;
            } else if (state is AssetCategoryManagementLoading && state.isOverlay) {
              isLoadingAssets = true;
            }

            return AlertDialog(
              title: Column(
                children: [
                  Text('Add/Remove Assets for "${category.name}"'),
                  TextField(
                    controller: _assetSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search assets...',
                      suffixIcon: _assetSearchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _assetSearchController.clear();
                          _searchAssetsForLinking();
                        },
                      )
                          : null,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 80.w, // Adjust width as needed
                height: 60.h, // Adjust height as needed
                child: isLoadingAssets
                    ? const Center(child: CircularProgressIndicator())
                    : selectableAssets.isEmpty
                    ? const Center(child: Text('No assets available to add.'))
                    : ListView.builder(
                  itemCount: selectableAssets.length,
                  itemBuilder: (context, index) {
                    final asset = selectableAssets[index];
                    final isSelected = currentSelected.contains(asset.id);
                    return CheckboxListTile(
                      title: Text(asset.name),
                      subtitle: Text(asset.assetId),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() { // Using setState for local dialog state
                          if (value == true) {
                            _selectedAssetsForAdding.add(asset.id!);
                          } else {
                            _selectedAssetsForAdding.remove(asset.id!);
                          }
                          // Update Bloc's internal selection state if needed
                          // For now, _selectedAssetsForAdding manages local dialog state
                        });
                        // Optionally dispatch event to update bloc's selected list if dialog is part of bloc state
                        // context.read<AssetCategoryManagementBloc>().add(ToggleAssetSelection(assetId: asset.id!));
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.read<AssetCategoryManagementBloc>().add(const ClearSelectedAssetsForLinking());
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _selectedAssetsForAdding.isEmpty
                      ? null
                      : () {
                    context.read<AssetCategoryManagementBloc>().add(
                      AddAssetsToSelectedCategory(
                        categoryId: category.id!,
                        assetIds: _selectedAssetsForAdding,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add Selected'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  void dispose() {
    _categoryNameController.dispose();
    _categoryCodeController.dispose();
    _categoryDescriptionController.dispose();
    _assetSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? Colors.white12.withOpacity(0.15) : Colors.white;
    final appBarSurfaceColor = isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F);
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;


    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Category Management', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: appBarSurfaceColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<AssetCategoryManagementBloc, AssetCategoryManagementState>(
        listener: (context, state) {
          if (state is AssetCategoryManagementSuccess) {
            context.showSnackBar(state.message); // Fix: using extension
            _selectedAssetsForAdding.clear(); // Clear selections after success
            _selectedAssetsForRemoval.clear();
          } else if (state is AssetCategoryManagementFailure && state.showDialog) {
            context.showErrorDialog(state.message); // Fix: using extension
          } else if (state is AssetCategoryManagementFailure) {
            context.showSnackBar(state.message); // Fix: using extension
          }
        },
        child: BlocBuilder<AssetCategoryManagementBloc, AssetCategoryManagementState>(
          builder: (context, state) {
            if (state is AssetCategoryManagementLoading && !state.isOverlay) {
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade600)));
            }

            List<AssetCategoryEntity> categories = [];
            AssetCategoryEntity? selectedCategory;
            List<AssetEntity> assetsInSelectedCategory = [];

            if (state is AssetCategoryManagementLoaded) {
              categories = state.categories;
              selectedCategory = state.selectedCategory;
              assetsInSelectedCategory = state.assetsInCategory;
            } else if (state is AssetLinkingSelectionState) { // If in asset selection sub-state
              categories = state.categories;
              selectedCategory = state.selectedCategory;
              assetsInSelectedCategory = state.assetsInCategory;
            } else if (state is AssetCategoryManagementLoading && state.isOverlay) {
              // If overlay loading, show existing content with progress indicator overlay
              final previousLoadedState = (context.read<AssetCategoryManagementBloc>().state is AssetCategoryManagementLoaded)
                  ? context.read<AssetCategoryManagementBloc>().state as AssetCategoryManagementLoaded
                  : (context.read<AssetCategoryManagementBloc>().state is AssetLinkingSelectionState
                  ? context.read<AssetCategoryManagementBloc>().state as AssetLinkingSelectionState
                  : null);

              if (previousLoadedState != null) {
                categories = previousLoadedState.categories;
                selectedCategory = previousLoadedState.selectedCategory;
                assetsInSelectedCategory = previousLoadedState.assetsInCategory;
              }
              // Show a loading overlay on top of existing content
              return Stack(
                children: [
                  _buildContent(l10n, isDarkMode, categories, selectedCategory, assetsInSelectedCategory, primaryTextColor, secondaryTextColor, cardColor),
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade600)),
                          SizedBox(height: 2.h),
                          Text(state.message ?? 'Loading...', style: GoogleFonts.poppins(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is AssetCategoryManagementFailure) {
              // Only show error if it's not an overlay failure (handled by SnackBar/Dialog)
              if (!state.showDialog) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 20.w, color: Colors.red.shade400),
                      SizedBox(height: 2.h),
                      Text(state.message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red.shade400)),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: _loadInitialData,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        child: Text(l10n.tryAgain, style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
            }


            return _buildContent(l10n, isDarkMode, categories, selectedCategory, assetsInSelectedCategory, primaryTextColor, secondaryTextColor, cardColor);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryFormDialog(),
        label: Text('Add New Category', style: GoogleFonts.poppins(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.teal,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent(
      AppLocalizations l10n,
      bool isDarkMode,
      List<AssetCategoryEntity> categories,
      AssetCategoryEntity? selectedCategory,
      List<AssetEntity> assetsInSelectedCategory,
      Color primaryTextColor,
      Color secondaryTextColor,
      Color cardColor,
      ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Categories',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: 2.h),
          categories.isEmpty
              ? Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Text('No categories found. Add a new one!', style: GoogleFonts.poppins(color: secondaryTextColor)),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(
                context,
                l10n,
                isDarkMode,
                category,
                primaryTextColor,
                secondaryTextColor,
                cardColor,
              );
            },
          ),
          SizedBox(height: 4.h),
          if (selectedCategory != null) ...[
            Text(
              'Assets in "${selectedCategory.name}"',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            SizedBox(height: 2.h),
            assetsInSelectedCategory.isEmpty
                ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Text('No assets in this category.', style: GoogleFonts.poppins(color: secondaryTextColor)),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assetsInSelectedCategory.length,
              itemBuilder: (context, index) {
                final asset = assetsInSelectedCategory[index];
                final isSelected = _selectedAssetsForRemoval.contains(asset.id);
                return _buildAssetListItem(
                  context,
                  isDarkMode,
                  asset,
                  isSelected,
                  onChanged: (bool? value) { // Fix: Pass onChanged as named parameter
                    setState(() {
                      if (value == true) {
                        _selectedAssetsForRemoval.add(asset.id!);
                      } else {
                        _selectedAssetsForRemoval.remove(asset.id!);
                      }
                    });
                  },
                );
              },
            ),
            SizedBox(height: 2.h),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _selectedAssetsForRemoval.isEmpty
                    ? null
                    : () {
                  final companyId = GetIt.instance<SessionService>().getActiveCompany()?.id;
                  if (companyId != null && selectedCategory != null) {
                    context.read<AssetCategoryManagementBloc>().add(
                      RemoveAssetsFromSelectedCategory(
                        categoryId: selectedCategory.id!,
                        assetIds: _selectedAssetsForRemoval,
                      ),
                    );
                    _selectedAssetsForRemoval.clear(); // Clear selection immediately
                  }
                },
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                label: const Text('Remove Selected Assets', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
            SizedBox(height: 10.h), // Space for FAB
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context,
      AppLocalizations l10n,
      bool isDarkMode,
      AssetCategoryEntity category,
      Color primaryTextColor,
      Color secondaryTextColor,
      Color cardColor,
      ) {
    // Fix: Directly use category.icon and category.color (assuming they are already IconData? and Color?)
    IconData categoryIcon = category.icon ?? Icons.category_outlined;
    Color categoryColor = category.color ?? Colors.teal.shade400;

    return Card(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    'Code: ${category.code}',
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: isDarkMode ? Colors.blueGrey.shade200 : Colors.blueGrey.shade700),
              onPressed: () => _showCategoryFormDialog(category: category),
              tooltip: 'Edit Category',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: isDarkMode ? Colors.red.shade300 : Colors.red.shade700),
              onPressed: () {
                final companyId = GetIt.instance<SessionService>().getActiveCompany()?.id;
                if (companyId != null && category.id != null) {
                  _showDeleteConfirmationDialog(category.id!, companyId, category.name);
                }
              },
              tooltip: 'Delete Category',
            ),
            IconButton(
              icon: Icon(Icons.add_box, color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700),
              onPressed: () {
                context.read<AssetCategoryManagementBloc>().add(
                  SelectCategoryForAssetManagement(
                    categoryId: category.id!,
                    companyId: GetIt.instance<SessionService>().getActiveCompany()!.id!,
                  ),
                );
                _showAssetLinkingDialog(category);
              },
              tooltip: 'Manage Assets',
            ),
          ],
        ),
      ),
    );
  }

  // Fix: Changed onChanged to be a named parameter in the signature
  Widget _buildAssetListItem(
      BuildContext context,
      bool isDarkMode,
      AssetEntity asset,
      bool isSelected,
      {required ValueSetter<bool?> onChanged} // Fix: Made onChanged a required named parameter
      ) {
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;

    return Card(
      color: cardColor,
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: CheckboxListTile(
        tileColor: isSelected ? (isDarkMode ? Colors.teal.shade900.withOpacity(0.5) : Colors.teal.shade50) : null,
        title: Text(
          asset.name,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: primaryTextColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          asset.assetId,
          style: GoogleFonts.poppins(fontSize: 9.sp, color: secondaryTextColor),
        ),
        value: isSelected,
        onChanged: onChanged,
        activeColor: Colors.teal,
        checkColor: Colors.white,
      ),
    );
  }
}