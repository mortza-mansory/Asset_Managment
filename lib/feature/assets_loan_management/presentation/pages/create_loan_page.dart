import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/create_loan/create_loan_bloc.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/create_loan/create_loan_event.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/create_loan/create_loan_state.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:assetsrfid/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import 'package:assetsrfid/feature/asset_managment/domain/entities/asset_entity.dart';


class CreateLoanPage extends StatefulWidget {
  const CreateLoanPage({super.key});

  @override
  State<CreateLoanPage> createState() => _CreateLoanPageState();
}

class _CreateLoanPageState extends State<CreateLoanPage> {
  final _assetController = TextEditingController(); // For displaying scanned asset name
  final _recipientController = TextEditingController(); // برای external recipient یا نمایش موقت نام کاربر
  final _rfidTagController = TextEditingController(); // Changed from _assetIdController to _rfidTagController
  final _recipientIdController = TextEditingController(); // برای recipientId
  final _phoneNumberController = TextEditingController(); // New: Controller for phone number

  final _dateController = TextEditingController();
  final _detailsController = TextEditingController();

  DateTime? _selectedEndDate;

  @override
  void dispose() {
    _assetController.dispose();
    _recipientController.dispose();
    _rfidTagController.dispose(); // Dispose the new controller
    _recipientIdController.dispose();
    _phoneNumberController.dispose();
    _dateController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
        _dateController.text = DateFormat('yyyy/MM/dd').format(_selectedEndDate!);
      });
    }
  }


  Future<void> _scanAsset() async {
    final resultRfid = await context.push<String>('/scan_page/rfid');
    if (resultRfid != null && mounted) {
      context.read<CreateLoanBloc>().add(GetAssetDetailsById(resultRfid));
    }
  }

  Future<void> _scanRecipient() async {
    final resultQrCode = await context.push<String>('/scan_page/qrcode');
    if (resultQrCode != null && mounted) {
      final userIdStringRaw = resultQrCode;
      String? userIdString;
      if (userIdStringRaw.startsWith('user_id:')) {
        userIdString = userIdStringRaw.split(':').last;
      } else {
        userIdString = userIdStringRaw;
      }

      final userId = int.tryParse(userIdString);
      if (userId != null) {
        _recipientIdController.text = userId.toString();
        _recipientController.text = 'User ID: $userId';
        _phoneNumberController.clear();
      } else {
        _recipientIdController.clear();
        _recipientController.text = resultQrCode;
        _phoneNumberController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.invalidQrCodeForUser)),
        );
      }
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
        child: BlocListener<CreateLoanBloc, CreateLoanState>(
          listener: (context, state) {
            if (state is AssetDetailsLoaded) {
              // Now setting rfidTag directly from asset entity
              _rfidTagController.text = state.asset.rfidTag ?? '';
              _assetController.text = state.asset.name;
            } else if (state is ScanFieldError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? l10n.unknownError)),
              );
              if (state.field == 'asset') {
                _assetController.clear();
                _rfidTagController.clear(); // Clear the rfidTagController
              } else if (state.field == 'recipient') {
                _recipientController.clear();
                _recipientIdController.clear();
                _phoneNumberController.clear();
              }
            } else if (state is CreateLoanSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.loanCreatedSuccessfully(state.loan.id.toString()))),
              );
              context.pop();
            } else if (state is CreateLoanError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? l10n.unknownError)),
              );
            }
          },
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
                _buildScanField(l10n.selectAssetFieldLabel, _assetController, Icons.nfc_rounded, _scanAsset, enabled: false),
                SizedBox(height: 2.5.h),
                // NEW: RFID Tag Field
                NewCustomTextField(
                  controller: _rfidTagController, // Using the new rfidTagController
                  labelText: l10n.rfidTagLabel, // New localization key
                  prefixIcon: Icons.qr_code_2_rounded,
                  keyboardType: TextInputType.text, // Changed to text keyboard type
                ),
                SizedBox(height: 2.5.h),
                _buildScanField(l10n.selectUserFieldLabel, _recipientController, Icons.qr_code_scanner_rounded, _scanRecipient, enabled: true),
                SizedBox(height: 2.5.h),
                NewCustomTextField(
                  controller: _phoneNumberController,
                  labelText: l10n.phoneNumberLabel,
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 2.5.h),
                NewCustomTextField(
                  controller: _dateController,
                  labelText: l10n.returnDateLabel,
                  prefixIcon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 2.5.h),
                NewCustomTextField(controller: _detailsController, labelText: l10n.notesLabel, prefixIcon: Icons.notes_rounded),
                SizedBox(height: 6.h),
                BlocBuilder<CreateLoanBloc, CreateLoanState>(
                  builder: (context, state) {
                    return NewCustomButton(
                      text: state is CreateLoanLoading ? l10n.creatingLoan : l10n.createLoanButton,
                      backgroundColor: Colors.blueGrey,
                      isLoading: state is CreateLoanLoading,
                      onPressed: state is CreateLoanLoading ? null : () {
                        // RFID Tag Validation
                        final enteredRfidTag = _rfidTagController.text.trim();
                        if (enteredRfidTag.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.rfidTagRequired)), // New localization key
                          );
                          return;
                        }

                        final recipientId = int.tryParse(_recipientIdController.text);
                        final externalRecipientText = _recipientController.text.trim();
                        final phoneNumber = _phoneNumberController.text.trim();

                        if (recipientId == null && externalRecipientText.isEmpty && phoneNumber.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.selectRecipientRequired)),
                          );
                          return;
                        }

                        if (_selectedEndDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.selectReturnDateRequired)),
                          );
                          return;
                        }

                        context.read<CreateLoanBloc>().add(
                          CreateLoanSubmitted(
                            rfidTag: enteredRfidTag, // Sending rfidTag directly from text field
                            recipientId: recipientId ?? 0,
                            externalRecipient: recipientId == null && externalRecipientText.isNotEmpty ? externalRecipientText : null,
                            phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
                            endDate: _selectedEndDate!,
                            details: _detailsController.text.isEmpty ? null : _detailsController.text,
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanField(String label, TextEditingController controller, IconData icon, VoidCallback onScan, {bool enabled = true}) {
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
                enabled: enabled,
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