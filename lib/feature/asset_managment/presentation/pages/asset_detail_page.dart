import 'dart:ui';

import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';

class StatusEvent {
  final String location;
  final DateTime timestamp;
  final String status;
  final IconData icon;
  final Color color;

  StatusEvent({
    required this.location,
    required this.timestamp,
    required this.status,
    required this.icon,
    required this.color,
  });
}

class AssetDetailPage extends StatefulWidget {
  final bool haveGPS;
  final int scannerConnectionState;

  const AssetDetailPage({
    super.key,
    this.haveGPS = true,
    this.scannerConnectionState = 1,
  });

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  bool _isConnectingToScanner = false;

  void _showEditConfirmationDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editAlertTitle, style: GoogleFonts.poppins()),
        content: Text(l10n.editAlertContent, style: GoogleFonts.poppins()),
        actions: <Widget>[
          TextButton(
            child: Text(l10n.editAlertCancel, style: GoogleFonts.poppins()),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ElevatedButton(
            child: Text(l10n.editAlertConfirm, style: GoogleFonts.poppins()),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.push('/asset_detail_edit');
            },
          ),
        ],
      ),
    );
  }
  void _handleRfidScan() {
    setState(() => _isConnectingToScanner = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (widget.scannerConnectionState == 1) {
        context.push('/rfid_validation/1');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.snackScannerNotFound,
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
      setState(() => _isConnectingToScanner = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor =
    isDarkMode ? const Color(0xFF1E1E20) : const Color(0xFFF4F6F8);
    final primaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final cardBackgroundColor =
    isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final secondaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;
    final iconColor =
    isDarkMode ? Colors.white.withOpacity(0.7) : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 12.h),
            child: Column(
              children: [
                _buildHeaderCard(context, cardBackgroundColor, primaryTextColor,
                    secondaryTextColor),
                _buildIdentifierCard(context, cardBackgroundColor,
                    primaryTextColor, secondaryTextColor, iconColor),
                _buildDetailsCard(context, cardBackgroundColor, primaryTextColor,
                    secondaryTextColor, iconColor),
                if (widget.haveGPS)
                  _buildGpsCard(
                      context, cardBackgroundColor, primaryTextColor),
                _buildStatusTimeline(context, cardBackgroundColor,
                    primaryTextColor, secondaryTextColor),
                _buildDescriptionCard(context, cardBackgroundColor,
                    primaryTextColor, secondaryTextColor),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildActionButtons(context, isDarkMode),
          ),
        ],
      ),
    );
  }
  Widget _buildHeaderCard(BuildContext context, Color cardBg, Color primaryText,
      Color secondaryText) {
    final l10n = context.l10n;
    final statusText = l10n.assetStatusActive;
    final statusColor = Colors.green.shade400;

    return Card(
      color: cardBg,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Icon(Icons.laptop_mac_outlined, size: 12.w, color: statusColor),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('لپ‌تاپ Dell XPS 15',
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryText)),
                  SizedBox(height: 0.5.h),
                  Text('LP-00125 • تجهیزات الکترونیکی',
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp, color: secondaryText)),
                  SizedBox(height: 1.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusText,
                        style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            color: statusColor,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1);
  }

  Widget _buildGpsCard(BuildContext context, Color cardBg, Color primaryText) {
    final ahvazLocation = const LatLng(31.3183, 48.6706);

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
                    initialCenter: ahvazLocation,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: ahvazLocation,
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

  Widget _buildIdentifierCard(BuildContext context, Color cardBg,
      Color primaryText, Color secondaryText, Color iconColor) {
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
            _buildIdCell(l10n.assetIdLabel, 'P-58290', iconColor, primaryText,
                secondaryText),
            VerticalDivider(width: 8.w, thickness: 1),
            _buildIdCell(l10n.assetRfidLabel, 'E28011700000020B02B5095C',
                iconColor, primaryText, secondaryText),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideX(begin: -0.1);
  }

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

  Widget _buildDetailsCard(BuildContext context, Color cardBg,
      Color primaryText, Color secondaryText, Color iconColor) {
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
            _buildDetailRow(
                l10n.assetSpecModel, 'XPS 9520', iconColor, secondaryText),
            _buildDetailRow(l10n.assetSpecSerial, 'SN-GH589J-2023', iconColor,
                secondaryText),
            _buildDetailRow(
                l10n.assetSpecRegDate, '1402/08/15', iconColor, secondaryText),
            _buildDetailRow(l10n.assetSpecWarrantyEnd, '1404/08/15', iconColor,
                secondaryText),
            _buildDetailRow(l10n.assetSpecLocation, 'انبار مرکزی', iconColor,
                secondaryText),
            _buildDetailRow(l10n.assetSpecCustodian, 'آقای رضایی', iconColor,
                secondaryText),
            _buildDetailRow(l10n.assetSpecValue, '۱۱۰،۰۰۰،۰۰۰ ریال', iconColor,
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
                  'CPU: Core i9, RAM: 32GB, SSD: 1TB',
                  isDarkMode ? Colors.teal.shade200 : Colors.teal.shade800,
                  primaryText,
                  isBold: true),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideX(begin: -0.1);
  }

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

  Widget _buildDescriptionCard(BuildContext context, Color cardBg,
      Color primaryText, Color secondaryText) {
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
              'لپ‌تاپ قدرتمند برای کارهای گرافیکی و پردازشی سنگین، تحویل داده شده به تیم توسعه جهت پروژه سامانه جدید اموال. دارای گارانتی دو ساله سازگار ارقام.',
              style: GoogleFonts.poppins(
                  fontSize: 11.sp, color: secondaryText, height: 1.6),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideX(begin: -0.1);
  }
  Widget _buildStatusTimeline(BuildContext context, Color cardBg,
      Color primaryText, Color secondaryText) {
    final l10n = context.l10n;
    final statusEvents = [
      StatusEvent(
          location: 'انبار مرکزی تهران',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          status: l10n.assetStatusActive,
          icon: Icons.qr_code_scanner_rounded,
          color: Colors.green),
      StatusEvent(
          location: 'خروج از انبار اصفهان',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          status: l10n.assetStatusInactive,
          icon: Icons.logout_rounded,
          color: Colors.orange),
      StatusEvent(
          location: 'ورود به انبار اصفهان',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          status: l10n.assetStatusActive,
          icon: Icons.login_rounded,
          color: Colors.blue),
    ];

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
            Text(l10n.statusHistoryTitle,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryText)),
            SizedBox(height: 2.h),
            ...List.generate(statusEvents.length, (index) {
              return _TimelineTile(
                event: statusEvents[index],
                isFirst: index == 0,
                isLast: index == statusEvents.length - 1,
                primaryTextColor: primaryText,
                secondaryTextColor: secondaryText,
              );
            }),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 300.ms).slideX(begin: -0.1);
  }
  Widget _buildActionButtons(BuildContext context, bool isDarkMode) {
    final l10n = context.l10n;
    final navBarBackgroundColor =
    isDarkMode ? const Color(0xFF2C2C2E) : Colors.white;

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
                  onPressed: () => context.push('/asset_history'),
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
                  onPressed: () {_showEditConfirmationDialog(context);},
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
class _TimelineTile extends StatelessWidget {
  final StatusEvent event;
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
                backgroundColor: event.color,
                child: Icon(event.icon, size: 2.5.w, color: Colors.white),
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
                    '${context.l10n.statusHistoryScannedAt} ${event.location}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${context.l10n.statusHistoryOnDate} ${event.timestamp.hour}:${event.timestamp.minute} - ${event.timestamp.year}/${event.timestamp.month}/${event.timestamp.day}',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: secondaryTextColor,
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