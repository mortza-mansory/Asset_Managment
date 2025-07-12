import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail_edit/asset_detail_edit_bloc.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail_edit/asset_detail_edit_event.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail_edit/asset_detail_edit_state.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssetDetailEditPage extends StatefulWidget {
  final AssetEntity asset;

  const AssetDetailEditPage({super.key, required this.asset});

  @override
  State<AssetDetailEditPage> createState() => _AssetDetailEditPageState();
}

class _AssetDetailEditPageState extends State<AssetDetailEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _modelController;
  late TextEditingController _serialController;
  late TextEditingController _locationController;
  late TextEditingController _custodianController;
  late TextEditingController _valueController;
  late TextEditingController _descriptionController;

  AssetStatus? _selectedStatus;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset.name);
    _modelController = TextEditingController(text: widget.asset.model);
    _serialController = TextEditingController(text: widget.asset.serialNumber);
    _locationController = TextEditingController(text: widget.asset.location);
    _custodianController = TextEditingController(text: widget.asset.custodian);
    _valueController = TextEditingController(text: widget.asset.value?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.asset.description);

    _selectedStatus = widget.asset.status;

  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _locationController.dispose();
    _custodianController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    context.read<AssetDetailEditBloc>().add(
      UpdateAssetDetails(
        assetId: widget.asset.id!,
        name: _nameController.text,
        model: _modelController.text,
        serialNumber: _serialController.text,
        location: _locationController.text,
        custodian: _custodianController.text,
        value: int.tryParse(_valueController.text),
        description: _descriptionController.text,
        status: _selectedStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor =
    isDarkMode ? const Color(0xFF1E1E20) : const Color(0xFFF4F6F8);
    final primaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Asset: ${widget.asset.name}', style: GoogleFonts.poppins(color: primaryTextColor)),
      ),
      body: BlocListener<AssetDetailEditBloc, AssetDetailEditState>(
        listener: (context, state) {
          if (state is AssetDetailEditSuccess) {
            context.showSnackBar(state.message);
            context.pop(state.updatedAsset);
          } else if (state is AssetDetailEditError) {
            context.showErrorDialog(state.message);
          }
        },
        child: BlocBuilder<AssetDetailEditBloc, AssetDetailEditState>(
          builder: (context, state) {
            bool isLoading = false;
            AssetEntity currentAsset = widget.asset;

            if (state is AssetDetailEditLoading) {
              isLoading = true;
            } else if (state is AssetDetailEditLoaded) {
              currentAsset = state.asset;
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NewCustomTextField(
                          controller: _nameController, labelText: 'نام دارایی'),
                      SizedBox(height: 2.h),
                      NewCustomTextField(
                          controller: _modelController,
                          labelText: l10n.assetSpecModel),
                      SizedBox(height: 2.h),
                      NewCustomTextField(
                          controller: _serialController,
                          labelText: l10n.assetSpecSerial),
                      SizedBox(height: 2.h),
                      NewCustomTextField(
                          controller: _locationController,
                          labelText: l10n.assetSpecLocation),
                      SizedBox(height: 2.h),
                      NewCustomTextField(
                          controller: _custodianController,
                          labelText: l10n.assetSpecCustodian),
                      SizedBox(height: 2.h),
                      NewCustomTextField(
                          controller: _valueController,
                          labelText: l10n.assetSpecValue,
                          keyboardType: TextInputType.number),
                      SizedBox(height: 2.h),
                      // Dropdown برای وضعیت (Status) دارایی
                      _buildStatusDropdown(context, l10n, isDarkMode),
                      SizedBox(height: 2.h),
                      NewCustomTextField(
                        controller: _descriptionController,
                        labelText: l10n.assetDescriptionTitle,
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade600)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomSheet: _buildSaveChangesButton(context, isDarkMode),
    );
  }

  // Dropdown برای انتخاب وضعیت دارایی
  Widget _buildStatusDropdown(BuildContext context, AppLocalizations l10n, bool isDarkMode) {
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final dropdownColor = isDarkMode ? Colors.black.withOpacity(0.15) : Colors.white;
    final borderColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;

    return DropdownButtonFormField<AssetStatus>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        labelStyle: GoogleFonts.poppins(color: isDarkMode ? Colors.white70 : Colors.black87),
        filled: true,
        fillColor: dropdownColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: borderColor, width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: borderColor, width: 0.8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade400, width: 1.5)),
      ),
      dropdownColor: isDarkMode ? const Color(0xFF2A2B2F) : Colors.white,
      style: GoogleFonts.poppins(color: primaryTextColor, fontSize: 11.sp),
      items: AssetStatus.values.map((status) {
        String localizedLabel;
        switch (status) {
          case AssetStatus.active: localizedLabel = l10n.assetStatusActive; break;
          case AssetStatus.inactive: localizedLabel = l10n.assetStatusInactive; break;
          case AssetStatus.maintenance: localizedLabel = l10n.assetStatusMaintenance; break;
          case AssetStatus.disposed: localizedLabel = l10n.assetStatusDisposed; break;
          case AssetStatus.on_loan: localizedLabel = l10n.assetStatusOnLoan; break;
        }
        return DropdownMenuItem(
          value: status,
          child: Text(localizedLabel),
        );
      }).toList(),
      onChanged: (AssetStatus? newValue) {
        setState(() {
          _selectedStatus = newValue;
        });
      },
    );
  }

  Widget _buildSaveChangesButton(BuildContext context, bool isDarkMode) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      width: double.infinity,
      color: isDarkMode
          ? const Color(0xFF2A2B2F)
          : Colors.white.withOpacity(0.95),
      child: ElevatedButton.icon(
        onPressed: _saveChanges, // فراخوانی متد ذخیره
        icon: const Icon(Icons.check_circle_outline),
        label: Text(l10n.saveChangesButton),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor:
          isDarkMode ? Colors.teal.shade500 : Colors.teal.shade700,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 13.sp),
        ),
      ),
    );
  }
}