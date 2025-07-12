// lib/feature/asset_managment/presentation/pages/asset_detail_page.dart

import 'dart:ui'; // برای ImageFilter.blur

import 'package:assetsrfid/core/utils/context_extensions.dart'; // برای l10n, showSnackBar, showErrorDialog
import 'package:assetsrfid/feature/asset_managment/data/models/asset_status_model.dart'; // برای AssetStatus enum
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';

import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail/asset_detail_bloc.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail/asset_detail_event.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/bloc/asset_detail/asset_detail_state.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_category_entity.dart';
import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_history_entity.dart';

// جدید: برای دسترسی به SessionService
import 'package:assetsrfid/core/services/session_service.dart';
import 'package:get_it/get_it.dart';


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


class AssetDetailPage extends StatefulWidget {
  final String rfidTag; // RFID tag را از طریق GoRouter دریافت می‌کنیم

  const AssetDetailPage({
    super.key,
    required this.rfidTag, // RFID tag اکنون اجباری است
  });

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  bool _isConnectingToScanner = false;

  @override
  void initState() {
    super.initState();
    context.read<AssetDetailBloc>().add(LoadAssetDetailByRfid(rfidTag: widget.rfidTag));
  }

  // جدید: نمایش Modal برای انتخاب نوع ویرایش
  void _showEditOptionsModal(BuildContext context, AssetEntity asset) {
    final l10n = context.l10n;
    final isDarkMode = context.read<ThemeBloc>().state.isDarkMode;
    final modalBackgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final primaryButtonColor = isDarkMode ? Colors.teal.shade700 : Colors.teal.shade400;
    final secondaryButtonColor = isDarkMode ? Colors.blueGrey.shade700 : Colors.blueGrey.shade400;

    // Fix: دریافت نقش کاربر از SessionService و بررسی دسترسی
    final sessionService = GetIt.instance<SessionService>();
    final userRole = sessionService.getActiveCompany()?.role;
    final bool canEditFullAsset = userRole == 'S' || userRole == 'A1' || userRole == 'A2'; // 'S' for SuperAdmin, 'A1' for Owner, 'A2' for Admin


    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // شفاف برای نمایش سایه
      builder: (modalContext) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 4.h + MediaQuery.of(modalContext).padding.bottom),
              decoration: BoxDecoration(
                color: modalBackgroundColor.withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose Edit Option', // یا از l10n استفاده کنید
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  ElevatedButton.icon(
                    onPressed: canEditFullAsset ? () {
                      Navigator.of(modalContext).pop();
                      context.push('/asset_detail_edit', extra: asset);
                    } : null, // دکمه غیرفعال می‌شود اگر کاربر دسترسی نداشته باشد
                    icon: const Icon(Icons.edit_note_outlined, color: Colors.white),
                    label: Text(
                      'Update Asset Information',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: Size(double.infinity, 5.h),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton.icon(
                    onPressed: () { // این دکمه برای همه کاربران فعال است
                      Navigator.of(modalContext).pop();
                      context.push('/asset_detail_edit_location', extra: asset);
                    },
                    icon: const Icon(Icons.location_on_outlined, color: Colors.white),
                    label: Text(
                      'Update Location Information',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryButtonColor,
                      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: Size(double.infinity, 5.h),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleRfidScan() async {
    setState(() => _isConnectingToScanner = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    context.push('/rfid_validation/scan_and_redirect_to_detail');

    setState(() => _isConnectingToScanner = false);
  }


  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1E1E20) : const Color(0xFFF4F6F8);
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final cardBackgroundColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;
    final iconColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: iconColor),
            onPressed: () {
              // رفرش داده‌ها
              context.read<AssetDetailBloc>().add(LoadAssetDetailByRfid(rfidTag: widget.rfidTag));
            },
          ),
        ],
      ),
      body: BlocConsumer<AssetDetailBloc, AssetDetailState>(
        listener: (context, state) {
          if (state is AssetDetailError) {
            context.showErrorDialog(state.message);
          }
        },
        builder: (context, state) {
          if (state is AssetDetailLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade600),
              ),
            );
          } else if (state is AssetDetailLoaded) {
            final asset = state.asset;
            final category = state.category;
            final history = state.history;

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 12.h),
                  child: Column(
                    children: [
                      _buildHeaderCard(context, cardBackgroundColor, primaryTextColor, secondaryTextColor, asset, category),
                      _buildIdentifierCard(context, cardBackgroundColor, primaryTextColor, secondaryTextColor, iconColor, asset),
                      _buildDetailsCard(context, cardBackgroundColor, primaryTextColor, secondaryTextColor, iconColor, asset),
                      // Fix: استفاده از locationAddress برای GPS
                      if (asset.locationAddress != null && _tryParseLatLng(asset.locationAddress!) != null)
                        _buildGpsCard(context, cardBackgroundColor, primaryTextColor, _tryParseLatLng(asset.locationAddress!)!),
                      _buildStatusTimeline(context, cardBackgroundColor, primaryTextColor, secondaryTextColor, history),
                      _buildDescriptionCard(context, cardBackgroundColor, primaryTextColor, secondaryTextColor, asset),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildActionButtons(context, isDarkMode, asset),
                ),
              ],
            );
          } else if (state is AssetDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 20.w, color: Colors.red.shade400),
                  SizedBox(height: 2.h),
                  Text(state.message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red.shade400)),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () => context.read<AssetDetailBloc>().add(LoadAssetDetailByRfid(rfidTag: widget.rfidTag)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: Text(l10n.tryAgain, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink(); // حالت پیش‌فرض یا Initial
        },
      ),
    );
  }

  // Helper function to parse "(lon,lat)" string to LatLng
  LatLng? _tryParseLatLng(String locationAddress) {
    try {
      final parts = locationAddress.replaceAll('(', '').replaceAll(')', '').split(',');
      if (parts.length == 2) {
        final longitude = double.parse(parts[0].trim());
        final latitude = double.parse(parts[1].trim());
        return LatLng(latitude, longitude); // LatLng expects (latitude, longitude)
      }
    } catch (e) {
      print('Error parsing location address: $e');
    }
    return null;
  }


  Widget _buildHeaderCard(
      BuildContext context,
      Color cardBg,
      Color primaryText,
      Color secondaryText,
      AssetEntity asset,
      AssetCategoryEntity? category,
      ) {
    final l10n = context.l10n;
    final statusColor = _getStatusColor(asset.status);

    // تابع کمکی برای ترجمه وضعیت دارایی از enum AssetStatus
    String _localizedAssetStatus(AssetStatus status, AppLocalizations l10n) {
      switch (status) {
        case AssetStatus.active: return l10n.assetStatusActive;
        case AssetStatus.inactive: return l10n.assetStatusInactive;
        case AssetStatus.maintenance: return l10n.assetStatusMaintenance;
        case AssetStatus.disposed: return l10n.assetStatusDisposed;
        case AssetStatus.on_loan: return l10n.assetStatusOnLoan;
        default: return status.name; // fallback
      }
    }
    final localizedStatus = _localizedAssetStatus(asset.status, l10n);


    return Card(
      color: cardBg,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Icon(category?.icon ?? Icons.category_outlined, size: 12.w, color: category?.color ?? statusColor),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${asset.assetId} • ${category?.name ?? 'No Category'}',
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: secondaryText),
                  ),
                  SizedBox(height: 1.h),
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
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1);
  }
  // GPS Card: نمایش نقشه با موقعیت دارایی
  Widget _buildGpsCard(
      BuildContext context, Color cardBg, Color primaryText, LatLng location) {
    return Card(
      color: cardBg,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.w, 4.w, 4.w, 2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.gpsLocationSectionTitle,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryText)),
            SizedBox(height: 1.5.h),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: location, // استفاده از موقعیت واقعی
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app', // نام پکیج شما
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: location, // استفاده از موقعیت واقعی
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
          ],
        ),
      ),
    ).animate().fadeIn(delay: 50.ms, duration: 300.ms).slideX(begin: -0.1);
  }

  // Identifier Card: نمایش Asset ID و RFID Tag
  Widget _buildIdentifierCard(BuildContext context, Color cardBg,
      Color primaryText, Color secondaryText, Color iconColor, AssetEntity asset) {
    final l10n = context.l10n;
    return Card(
      color: cardBg,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            _buildIdCell(l10n.assetIdLabel, asset.assetId, iconColor, primaryText, secondaryText),
            VerticalDivider(width: 8.w, thickness: 1),
            _buildIdCell(l10n.assetRfidLabel, asset.rfidTag, iconColor, primaryText, secondaryText),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideX(begin: -0.1);
  }

  // Id Cell Helper
  Widget _buildIdCell(String label, String value, Color iconColor,
      Color primaryText, Color secondaryText) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: secondaryText,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 0.5.h),
          Text(value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryText)),
        ],
      ),
    );
  }

  // Details Card: نمایش مشخصات فنی، سریال، تاریخ‌ها و...
  Widget _buildDetailsCard(BuildContext context, Color cardBg,
      Color primaryText, Color secondaryText, Color iconColor, AssetEntity asset) {
    final l10n = context.l10n;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: cardBg,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.assetSpecsSectionTitle,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryText)),
            Divider(height: 3.h),
            _buildDetailRow(l10n.assetSpecModel, asset.model ?? 'N/A', iconColor, secondaryText),
            _buildDetailRow(l10n.assetSpecSerial, asset.serialNumber ?? 'N/A', iconColor, secondaryText),
            _buildDetailRow(
                l10n.assetSpecRegDate,
                asset.registrationDate != null ? '${asset.registrationDate!.year}/${asset.registrationDate!.month}/${asset.registrationDate!.day}' : 'N/A',
                iconColor,
                secondaryText),
            _buildDetailRow(
                l10n.assetSpecWarrantyEnd,
                asset.warrantyEndDate != null ? '${asset.warrantyEndDate!.year}/${asset.warrantyEndDate!.month}/${asset.warrantyEndDate!.day}' : 'N/A',
                iconColor,
                secondaryText),
            _buildDetailRow(l10n.assetSpecLocation, asset.location ?? 'N/A', iconColor, secondaryText),
            _buildDetailRow(l10n.assetSpecCustodian, asset.custodian ?? 'N/A', iconColor, secondaryText),
            _buildDetailRow(
                l10n.assetSpecValue,
                asset.value != null ? '${asset.value} ${l10n.currencyUnit}' : 'N/A',
                iconColor,
                secondaryText),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: (isDarkMode ? Colors.teal.shade900 : Colors.teal.shade50)
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildDetailRow(
                  l10n.assetTechSpecsTitle,
                  asset.technicalSpecs ?? 'N/A', // نمایش مشخصات فنی واقعی
                  isDarkMode ? Colors.teal.shade200 : Colors.teal.shade800,
                  primaryText,
                  isBold: true),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideX(begin: -0.1);
  }

  // Detail Row Helper
  Widget _buildDetailRow(
      String label, String value, Color labelColor, Color valueColor,
      {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: labelColor,
                  fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: valueColor,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Description Card: نمایش توضیحات دارایی
  Widget _buildDescriptionCard(BuildContext context, Color cardBg,
      Color primaryText, Color secondaryText, AssetEntity asset) {
    final l10n = context.l10n;
    return Card(
      color: cardBg,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.assetDescriptionTitle,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryText)),
            Divider(height: 3.h),
            Text(
              asset.description ?? 'N/A', // نمایش توضیحات واقعی
              style: GoogleFonts.poppins(
                  fontSize: 11.sp, color: secondaryText, height: 1.6),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideX(begin: -0.1);
  }

  // Status Timeline: نمایش تاریخچه وضعیت دارایی
  Widget _buildStatusTimeline(
      BuildContext context,
      Color cardBg,
      Color primaryText,
      Color secondaryText,
      List<AssetHistoryEntity> history,
      ) {
    final l10n = context.l10n;

    return Card(
      color: cardBg,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statusHistoryTitle,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            SizedBox(height: 2.h),
            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Text(
                    'No history available.',
                    style: GoogleFonts.poppins(color: secondaryText),
                  ),
                ),
              )
            else
              ...history.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                return _TimelineTile(
                  event: event,
                  isFirst: index == 0,
                  isLast: index == history.length - 1,
                  primaryTextColor: primaryText,
                  secondaryTextColor: secondaryText,
                );
              }).toList(),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 300.ms).slideX(begin: -0.1);
  }
  // Action Buttons: دکمه‌های اسکن RFID، تاریخچه و ویرایش
  Widget _buildActionButtons(BuildContext context, bool isDarkMode, AssetEntity asset) {
    final l10n = context.l10n;
    final navBarBackgroundColor = isDarkMode ? const Color(0xFF2C2C2E) : Colors.white;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: navBarBackgroundColor.withOpacity(0.8),
            border: Border(
                top: BorderSide(
                    color: Colors.white.withOpacity(0.1), width: 1.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/asset_history', extra: asset.id), // ارسال asset ID به صفحه تاریخچه
                  icon: const Icon(Icons.history_rounded),
                  label: Text(l10n.assetHistoryButton),
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                    isDarkMode ? Colors.white70 : Colors.black54,
                    backgroundColor:
                    isDarkMode ? Colors.white12 : Colors.grey.shade200,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isConnectingToScanner ? null : _handleRfidScan,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: isDarkMode
                        ? Colors.blueGrey.shade500
                        : Colors.blueGrey.shade700,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle:
                    GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  child: _isConnectingToScanner
                      ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ))
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.nfc_outlined),
                      SizedBox(width: 2.w),
                      Text(l10n.assetRfidScan)
                    ],
                  ),
                ),
              ),
              SizedBox(width: 3.w),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {_showEditOptionsModal(context, asset);}, // فراخوانی Modal جدید
                  icon: const Icon(Icons.edit_note_outlined),
                  label: Text(l10n.assetEditButton),
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                    isDarkMode ? Colors.white70 : Colors.black54,
                    backgroundColor:
                    isDarkMode ? Colors.white12 : Colors.grey.shade200,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.2);
  }
}

// _TimelineTile: ویجت نمایش یک آیتم در تایم‌لاین تاریخچه
class _TimelineTile extends StatelessWidget {
  final AssetHistoryEntity event; // اکنون از AssetHistoryEntity استفاده می‌کند
  final bool isFirst;
  final bool isLast;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const _TimelineTile({
    required this.event,
    required this.isFirst,
    required this.isLast,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    // ترجمه نوع رویداد (مثلاً "scanned" به "اسکن شد")
    // فرض می‌کنیم در Localizations متدهایی برای ترجمه eventType ها دارید
    String localizedEventType(String eventType) {
      // این بخش باید با AppLocalizations شما هماهنگ شود
      switch(eventType.toLowerCase()) {
        case 'scanned': return context.l10n.assetEventTypeScanned;
        case 'moved': return context.l10n.assetEventTypeMoved;
        case 'assigned': return context.l10n.assetEventTypeAssigned;
        case 'registered': return context.l10n.assetEventTypeRegistered;
        case 'loaned': return context.l10n.assetEventTypeLoaned;
        case 'returned': return context.l10n.assetEventTypeReturned;
        default: return eventType;
      }
    }


    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              if (!isFirst)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade600,
                  ),
                ),
              CircleAvatar(
                radius: 1.8.w,
                backgroundColor: event.eventColor, // استفاده از رنگ از Entity
                child: Icon(event.eventIcon, size: 2.5.w, color: Colors.white), // استفاده از آیکون از Entity
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${localizedEventType(event.eventType)}: ${event.location ?? 'N/A'}', // استفاده از eventType و location واقعی
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${context.l10n.statusHistoryOnDate} ${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')} - ${event.timestamp.year}/${event.timestamp.month}/${event.timestamp.day}',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: secondaryTextColor,
                    ),
                  ),
                  if (event.details != null && event.details!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: Text(
                        event.details!,
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          color: secondaryTextColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}