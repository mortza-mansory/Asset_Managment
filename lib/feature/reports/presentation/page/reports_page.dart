import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';

enum TimeFilter { daily, weekly, monthly, quarterly, sixMonth, yearly }

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  TimeFilter _selectedFilter = TimeFilter.monthly;

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.push('/home'),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateFilter(context),
              SizedBox(height: 2.h),
              _buildReportCard(
                context: context,
                title: l10n.categoryDistributionTitle,
                child: _buildPieChart(context),
              ),
              SizedBox(height: 2.h),
              _buildReportCard(
                context: context,
                title: l10n.scanActivityTitle,
                child: _buildBarChart(context),
              ),
              SizedBox(height: 2.h),
              _buildReportCard(
                context: context,
                title: l10n.topScannedTitle,
                child: _buildTopItemsList(context),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    final l10n = context.l10n;
    final filters = {
      TimeFilter.daily: l10n.dateDaily,
      TimeFilter.weekly: l10n.dateWeekly,
      TimeFilter.monthly: l10n.dateMonthly,
      TimeFilter.quarterly: l10n.dateQuarterly,
      TimeFilter.sixMonth: l10n.dateSixMonth,
      TimeFilter.yearly: l10n.dateYearly,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reportDateFilter, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.sp)),
        SizedBox(height: 1.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: ChoiceChip(
                  label: Text(entry.value),
                  selected: _selectedFilter == entry.key,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFilter = entry.key);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard({required BuildContext context, required String title, required Widget child}) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final cardBackgroundColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

    return Card(
      color: cardBackgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
                ),
                TextButton.icon(
                  icon: Icon(Icons.download_for_offline_outlined, size: 5.w),
                  label: Text(context.l10n.exportButton),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.exportingSnackbar)));
                  },
                )
              ],
            ),
            Divider(height: 3.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final List<PieChartSectionData> sections = [
      PieChartSectionData(value: 40, title: '40%', color: Colors.blue.shade400, radius: 20.w, titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
      PieChartSectionData(value: 30, title: '30%', color: Colors.green.shade400, radius: 20.w, titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
      PieChartSectionData(value: 15, title: '15%', color: Colors.orange.shade400, radius: 20.w, titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
      PieChartSectionData(value: 15, title: '15%', color: Colors.red.shade400, radius: 20.w, titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
    ];
    final List<String> titles = [
      l10n.categoryElectronics,
      l10n.categoryFurniture,
      l10n.categoryVehicles,
      l10n.categoryTools,
    ];

    return SizedBox(
      height: 25.h,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 10.w,
                sectionsSpace: 2,
              ),
            ).animate().fadeIn(duration: 500.ms).scale(),
          ),
          SizedBox(width: 5.w),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(sections.length, (index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.5.h),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, color: sections[index].color),
                      SizedBox(width: 2.w),
                      Text(titles[index], style: TextStyle(fontSize: 11.sp)),
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    return SizedBox(
      height: 25.h,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.lightBlue, width: 15)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.lightBlue, width: 15)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.lightBlue, width: 15)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.lightBlue, width: 15)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: Colors.lightBlue, width: 15)]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10, color: Colors.lightBlue, width: 15)]),
          ],
          titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('M${value.toInt()+1}')))
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.5),
    );
  }

  Widget _buildTopItemsList(BuildContext context) {
    return Column(
      children: [
        _buildTopItem(context, 'لپ‌تاپ Dell XPS 15', '342 اسکن', Icons.laptop_mac_outlined, Colors.blue, 0),
        _buildTopItem(context, 'دریل شارژی Bosch', '210 اسکن', Icons.build_circle_outlined, Colors.red, 1),
        _buildTopItem(context, 'هارد اکسترنال WD', '188 اسکن', Icons.save_outlined, Colors.orange, 2),
      ],
    );
  }

  Widget _buildTopItem(BuildContext context, String name, String scanCount, IconData icon, Color color, int index) {
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(name, style: GoogleFonts.poppins(fontSize: 12.sp, color: primaryTextColor)),
          ),
          Text(scanCount, style: GoogleFonts.poppins(fontSize: 11.sp, color: secondaryTextColor, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: -0.2);
  }
}