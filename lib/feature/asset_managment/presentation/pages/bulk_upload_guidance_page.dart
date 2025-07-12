import 'package:assetsrfid/core/constants/api_constatns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/context_extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/onboarding_scaffold.dart';
import '../../../../feature/localization/presentation/bloc/localization_bloc.dart';
import '../bloc/bulk_upload/bulk_upload_bloc.dart';
import '../../../../core/services/session_service.dart';


class BulkUploadGuidancePage extends StatefulWidget {
  const BulkUploadGuidancePage({super.key});

  @override
  State<BulkUploadGuidancePage> createState() => _BulkUploadGuidancePageState();
}

class _BulkUploadGuidancePageState extends State<BulkUploadGuidancePage> {
  bool _showBanner = true;
  late final SessionService _sessionService;

  @override
  void initState() {
    super.initState();
    _sessionService = GetIt.instance<SessionService>();
    _checkBannerStatus();
  }

  void _checkBannerStatus() {
    setState(() {
      _showBanner = !_sessionService.hasSeenBulkUploadBanner();
    });
  }

  void _hideBannerPermanently() {
    _sessionService.markBulkUploadBannerAsSeen();
    setState(() {
      _showBanner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.read<LocalizationBloc>().state.locale.languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> headers = [
      {"en": "Asset ID", "fa": "شناسه دارایی", "required": true},
      {"en": "Asset Name", "fa": "نام دارایی", "required": true},
      {"en": "RFID Tag", "fa": "تگ RFID", "required": true},
      {"en": "Category Name", "fa": "نام دسته‌بندی", "required": true},
      {"en": "Model", "fa": "مدل", "required": false},
      {"en": "Serial Number", "fa": "شماره سریال", "required": false},
      {"en": "Technical Specs", "fa": "مشخصات فنی", "required": false},
      {"en": "Location", "fa": "مکان", "required": false},
      {"en": "Location Address", "fa": "آدرس مکان", "required": false},
      {"en": "Custodian", "fa": "نگهدارنده", "required": false},
      {"en": "Value", "fa": "ارزش", "required": false},
      {"en": "Registration Date", "fa": "تاریخ ثبت", "required": false},
      {"en": "Warranty End Date", "fa": "تاریخ پایان گارانتی", "required": false},
      {"en": "Description", "fa": "توضیحات", "required": false},
      {"en": "Status", "fa": "وضعیت", "required": false},
    ];

    final headerTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.87);
    final sectionTitleColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.9);
    final bodyTextColor = isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8);
    final noteTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6);


    return OnboardingScaffold(
      title: context.l10n.bulk_upload_guidance_title,
      currentStep: 1,
      totalSteps: 1,
      onBack: () {
        _sessionService.markBulkUploadBannerAsSeen();
        context.go('/home');
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.bulk_upload_guidance_description,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: bodyTextColor,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic),
            SizedBox(height: 3.h),

            if (_showBanner)
              Card(
                margin: EdgeInsets.only(bottom: 3.h),
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(isDarkMode ? 0.2 : 0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.bulk_upload_banner_title,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        context.l10n.bulk_upload_banner_message,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5.sp,
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: _hideBannerPermanently,
                          child: Text(
                            context.l10n.hide_banner_button,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 300.ms).slideY(begin: 0.2, curve: Curves.easeOut),

            Text(
              context.l10n.required_fields,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic),
            SizedBox(height: 1.5.h),
            ...headers.where((h) => h["required"]).map((h) => Padding(
              padding: EdgeInsets.only(left: 2.w, top: 0.5.h),
              child: Text(
                '• ${h[currentLocale]}',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: bodyTextColor,
                ),
              ),
            )).toList().animate(interval: 50.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),
            SizedBox(height: 3.h),

            // Optional Fields Section
            Text(
              context.l10n.optional_fields,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic),
            SizedBox(height: 1.5.h),
            ...headers.where((h) => !h["required"]).map((h) => Padding(
              padding: EdgeInsets.only(left: 2.w, top: 0.5.h),
              child: Text(
                '• ${h[currentLocale]}',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: bodyTextColor,
                ),
              ),
            )).toList().animate(interval: 50.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),
            SizedBox(height: 4.h),

            NewCustomButton(
              onPressed: () async {
                final Uri url = Uri.parse('${ApiConstants.baseUrl}/assets/download_excel_template/$currentLocale');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.template_download_started_in_browser),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.could_not_launch_download_link),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              text: context.l10n.download_template_button,
              icon: Icons.download,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 4,
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, curve: Curves.easeOutExpo),
            SizedBox(height: 2.h),

            NewCustomButton(
              onPressed: () {
                context.go('/bulk_upload');
              },
              text: context.l10n.go_to_upload_page,
              icon: Icons.upload_file,
              backgroundColor: isDarkMode ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3) : Theme.of(context).colorScheme.secondaryContainer,
              textColor: isDarkMode ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSecondaryContainer,
              elevation: 2,
            ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutExpo),
            SizedBox(height: 3.h),

            BlocConsumer<BulkUploadBloc, BulkUploadState>(
              listener: (context, state) async {
                if (state is BulkUploadError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is BulkUploadLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: 3.h),

            // Notes Section
            Text(
              context.l10n.bulk_upload_category_note,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontStyle: FontStyle.italic,
                color: noteTextColor,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            SizedBox(height: 1.h),
            Text(
              context.l10n.bulk_upload_status_note,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontStyle: FontStyle.italic,
                color: noteTextColor,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }
}