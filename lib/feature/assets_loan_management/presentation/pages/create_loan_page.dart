import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:assetsrfid/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CreateLoanPage extends StatefulWidget {
  const CreateLoanPage({super.key});

  @override
  State<CreateLoanPage> createState() => _CreateLoanPageState();
}

class _CreateLoanPageState extends State<CreateLoanPage> {
  final _assetController = TextEditingController();
  final _recipientController = TextEditingController();
  final _dateController = TextEditingController();
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _assetController.dispose();
    _recipientController.dispose();
    _dateController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _scanAsset() async {
    final result = await context.push<String>('/scan_page/rfid');
    if (result != null && mounted) {
      setState(() {
        _assetController.text = result;
      });
    }
  }

  Future<void> _scanRecipient() async {
    final result = await context.push<String>('/scan_page/qrcode');
    if (result != null && mounted) {
      setState(() {
        _recipientController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.87);
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.createLoanPageTitle,
                style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
              SizedBox(height: 1.h),
              Text(
                l10n.createLoanPageSubtitle,
                style: GoogleFonts.poppins(fontSize: 13.sp, color: secondaryTextColor, fontWeight: FontWeight.w500),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
              SizedBox(height: 5.h),
              _buildScanField(l10n.selectAssetFieldLabel, _assetController, Icons.nfc_rounded, _scanAsset),
              SizedBox(height: 2.5.h),
              _buildScanField(l10n.selectUserFieldLabel, _recipientController, Icons.qr_code_scanner_rounded, _scanRecipient),
              SizedBox(height: 2.5.h),
              NewCustomTextField(controller: _dateController, labelText: l10n.returnDateLabel, prefixIcon: Icons.calendar_today_outlined, keyboardType: TextInputType.datetime),
              SizedBox(height: 2.5.h),
              NewCustomTextField(controller: _detailsController, labelText: l10n.notesLabel, prefixIcon: Icons.notes_rounded),
              SizedBox(height: 6.h),
              NewCustomButton(
                text: l10n.createLoanButton,
                backgroundColor: Colors.blueGrey,
                onPressed: () => context.pop(),
              ),
              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanField(String label, TextEditingController controller, IconData icon, VoidCallback onScan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade500)),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: NewCustomTextField(
                controller: controller,
                labelText: '',
                prefixIcon: icon,
              ),
            ),
            SizedBox(width: 2.w),
            ElevatedButton(
              onPressed: onScan,
              child: Text(context.l10n.scanButton),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h)),
            )
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }
}