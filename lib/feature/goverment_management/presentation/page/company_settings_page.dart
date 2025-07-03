import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/goverment_management/domain/entities/company_overview_entity.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/bloc/company_settings/company_settings_bloc.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CompanySettingsPage extends StatelessWidget {
  const CompanySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CompanySettingsBloc>().add(LoadCompanyOverview());
    return const CompanySettingsView();
  }
}

class CompanySettingsView extends StatelessWidget {
  const CompanySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF4F6F8);
    final indicatorColor = Colors.teal.shade400;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.companySettingsTitle, style: GoogleFonts.poppins()),
          backgroundColor: isDarkMode ? const Color(0xFF232428) : Colors.white,
          elevation: 1,
          bottom: TabBar(
            indicatorColor: indicatorColor,
            labelColor: indicatorColor,
            unselectedLabelColor: isDarkMode ? Colors.white54 : Colors.black54,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: l10n.companySettingsUsersTab),
              Tab(text: l10n.companySettingsDetailsTab),
              Tab(text: l10n.companySettingsExportTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UsersView(),
            _DetailsView(),
            _ExportView(),
          ],
        ),
      ),
    );
  }
}

// ویجت تب "جزئیات"
class _DetailsView extends StatelessWidget {
  const _DetailsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanySettingsBloc, CompanySettingsState>(
      builder: (context, state) {
        if (state is CompanySettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CompanyOverviewLoaded) {
          return _buildDetailsContent(context, state.overview);
        }
        if (state is CompanySettingsFailure) {
          return Center(child: Text('خطا: ${state.message}'));
        }
        return const Center(child: Text('در حال بارگذاری اطلاعات...'));
      },
    );
  }

  Widget _buildDetailsContent(BuildContext context, CompanyOverviewEntity overview) {
    final l10n = context.l10n;
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        _buildInfoCard(
          context,
          icon: Icons.bar_chart_rounded,
          title: 'آمار کلی',
          children: [
            _buildStatRow(l10n.companyDetailsUserCount, overview.userCount.toString(), Icons.people_outline_rounded),
            _buildStatRow(l10n.companyDetailsAssetsCount, overview.assetsCount.toString(), Icons.widgets_outlined),
          ],
        ),
        SizedBox(height: 2.h),
        _buildInfoCard(
          context,
          icon: Icons.settings_suggest_outlined,
          title: 'وضعیت و ویرایش',
          children: [
            _buildStatRow(l10n.companyDetailsStatus,
                overview.isActive ? l10n.companyStatusActive : l10n.companyStatusInactive,
                overview.isActive ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                valueColor: overview.isActive ? Colors.green.shade400 : Colors.red.shade400
            ),
            // TODO: Add company details edit functionality
          ],
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required List<Widget> children}) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    return Card(
      color: isDarkMode ? const Color(0xFF232428) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          SizedBox(width: 3.w),
          Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}

// ویجت تب "کاربران" (فعلاً Placeholder)
class _UsersView extends StatelessWidget {
  const _UsersView();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('صفحه مدیریت کاربران به زودی...'));
  }
}

// ویجت تب "خروجی"
class _ExportView extends StatelessWidget {
  const _ExportView();
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.cloud_download_outlined, size: 25.w, color: Colors.teal.shade200),
          SizedBox(height: 3.h),
          Text(
            l10n.exportDataButton,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2.h),
          Text(
            l10n.exportDataDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 5.h),
          ElevatedButton.icon(
            onPressed: () { /* TODO: Implement export logic */ },
            icon: const Icon(Icons.download_rounded),
            label: Text(l10n.exportDataButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              textStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ).animate().fadeIn(),
    );
  }
}