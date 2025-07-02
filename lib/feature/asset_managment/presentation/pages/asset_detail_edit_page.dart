import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AssetDetailEditPage extends StatefulWidget {
  const AssetDetailEditPage({super.key});

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'لپ‌تاپ Dell XPS 15');
    _modelController = TextEditingController(text: 'XPS 9520');
    _serialController = TextEditingController(text: 'SN-GH589J-2023');
    _locationController = TextEditingController(text: 'انبار مرکزی');
    _custodianController = TextEditingController(text: 'آقای رضایی');
    _valueController = TextEditingController(text: '۱۱۰،۰۰۰،۰۰۰ ریال');
    _descriptionController = TextEditingController(
        text:
        'لپ‌تاپ قدرتمند برای کارهای گرافیکی و پردازشی سنگین، تحویل داده شده به تیم توسعه جهت پروژه سامانه جدید اموال. دارای گارانتی دو ساله سازگار ارقام.');
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
      ),
      body: SingleChildScrollView(
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
                controller: _valueController, labelText: l10n.assetSpecValue),
            SizedBox(height: 2.h),
            NewCustomTextField(
              controller: _descriptionController,
              labelText: l10n.assetDescriptionTitle,
            //  maxLines: 4,
            ),
          ],
        ),
      ),
      bottomSheet: _buildSaveChangesButton(context, isDarkMode),
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
        onPressed: () {
          context.pop();
        },
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