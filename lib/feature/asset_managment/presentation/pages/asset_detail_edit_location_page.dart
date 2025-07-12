// lib/feature/asset_managment/presentation/pages/asset_detail_edit_location_page.dart

import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Import Entity دارایی
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';

// Import BLoC برای به‌روزرسانی دارایی
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail_edit/asset_detail_edit_bloc.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail_edit/asset_detail_edit_event.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail_edit/asset_detail_edit_state.dart';


class AssetDetailEditLocationPage extends StatefulWidget {
  final AssetEntity asset; // دریافت AssetEntity از GoRouter extra

  const AssetDetailEditLocationPage({super.key, required this.asset});

  @override
  State<AssetDetailEditLocationPage> createState() => _AssetDetailEditLocationPageState();
}

class _AssetDetailEditLocationPageState extends State<AssetDetailEditLocationPage> {
  late TextEditingController _locationController;
  LatLng? _selectedLocationOnMap;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.asset.location ?? '');
    // Fix: مقداردهی اولیه _selectedLocationOnMap از locationAddress رشته‌ای
    _selectedLocationOnMap = _parseLocationAddress(widget.asset.locationAddress);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  // Helper to parse "(lon,lat)" string to LatLng
  LatLng? _parseLocationAddress(String? locationAddress) {
    if (locationAddress == null || locationAddress.isEmpty) return null;
    try {
      final parts = locationAddress.replaceAll('(', '').replaceAll(')', '').split(',');
      if (parts.length == 2) {
        final longitude = double.parse(parts[0].trim());
        final latitude = double.parse(parts[1].trim());
        return LatLng(latitude, longitude); // LatLng constructor is LatLng(latitude, longitude)
      }
    } catch (e) {
      print('Error parsing location address "$locationAddress": $e');
    }
    return null;
  }

  // Helper to format LatLng to "(lon,lat)" string
  String? _formatLatLngToLocationAddress(LatLng? latLng) {
    if (latLng == null) return null;
    return '(${latLng.longitude.toStringAsFixed(6)},${latLng.latitude.toStringAsFixed(6)})'; // Format as "(lon,lat)" with precision
  }


  void _saveChanges() {
    if (_locationController.text.isEmpty) {
      context.showSnackBar('Location field cannot be empty.');
      return;
    }

    context.read<AssetDetailEditBloc>().add(
      UpdateAssetDetails(
        assetId: widget.asset.id!,
        location: _locationController.text,
        locationAddress: _formatLatLngToLocationAddress(_selectedLocationOnMap), // Fix: ارسال locationAddress رشته‌ای
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1E1E20) : const Color(0xFFF4F6F8);
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Location: ${widget.asset.name}', style: GoogleFonts.poppins(color: primaryTextColor)),
      ),
      body: BlocListener<AssetDetailEditBloc, AssetDetailEditState>(
        listener: (context, state) {
          if (state is AssetDetailEditSuccess) {
            context.showSnackBar(state.message);
            context.pop(state.updatedAsset); // بازگشت به صفحه قبل با Asset به‌روز شده
          } else if (state is AssetDetailEditError) {
            context.showErrorDialog(state.message);
          }
        },
        child: BlocBuilder<AssetDetailEditBloc, AssetDetailEditState>(
          builder: (context, state) {
            bool isLoading = false;
            if (state is AssetDetailEditLoading) {
              isLoading = true;
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Location:', // یا از l10n
                        style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
                      ),
                      SizedBox(height: 1.h),
                      NewCustomTextField( // Fix: استفاده از CustomTextField
                        controller: _locationController,
                        labelText: l10n.assetSpecLocation, // از l10n
                        validator: (value) => value!.isEmpty ? 'Location cannot be empty' : null, // اعتبارسنجی
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Select Location on Map (Optional):', // یا از l10n
                        style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
                      ),
                      SizedBox(height: 1.h),
                      // نقشه (Dummy Map)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: _selectedLocationOnMap ?? const LatLng(31.3183, 48.6706), // مرکز پیش‌فرض اهواز
                              initialZoom: _selectedLocationOnMap != null ? 14.0 : 10.0,
                              onTap: (tapPosition, latLng) { // قابلیت انتخاب موقعیت با تپ
                                setState(() {
                                  _selectedLocationOnMap = latLng;
                                });
                                context.showSnackBar('Location selected: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}');
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              if (_selectedLocationOnMap != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 80.0,
                                      height: 80.0,
                                      point: _selectedLocationOnMap!,
                                      child: Icon(
                                        Icons.location_pin,
                                        color: Colors.red.shade600,
                                        size: 12.w,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h), // فضای خالی برای دکمه ذخیره
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
      bottomSheet: _buildSaveChangesButton(context, l10n, isDarkMode),
    );
  }

  Widget _buildSaveChangesButton(BuildContext context, AppLocalizations l10n, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      width: double.infinity,
      color: isDarkMode
          ? const Color(0xFF2A2B2F)
          : Colors.white.withOpacity(0.95),
      child: ElevatedButton.icon(
        onPressed: _saveChanges,
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