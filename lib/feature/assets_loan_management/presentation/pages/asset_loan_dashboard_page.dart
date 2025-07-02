import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:intl/intl.dart';

class Loan {
  final String assetName;
  final String personName;
  final DateTime dueDate;
  final IconData assetIcon;
  final Color itemColor;

  Loan(
      {required this.assetName,
        required this.personName,
        required this.dueDate,
        required this.assetIcon,
        required this.itemColor});
}

class AssetLoanDashboardPage extends StatefulWidget {
  const AssetLoanDashboardPage({super.key});

  @override
  State<AssetLoanDashboardPage> createState() => _AssetLoanDashboardPageState();
}

class _AssetLoanDashboardPageState extends State<AssetLoanDashboardPage>
    with SingleTickerProviderStateMixin {
  late List<Loan> myLoans;
  late List<Loan> loanedOut;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
  }

  void _initializeData() {
    final l10n = context.l10n;
    myLoans = [
      Loan(
          assetName: 'دوربین Nikon Z6',
          personName: l10n.loanFrom + ' واحد روابط عمومی',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          assetIcon: Icons.camera_alt_outlined,
          itemColor: Colors.blueGrey),
      Loan(
          assetName: 'تبلت Apple iPad Pro',
          personName: l10n.loanFrom + ' تیم طراحی',
          dueDate: DateTime.now().add(const Duration(days: 12)),
          assetIcon: Icons.tablet_mac_outlined,
          itemColor: Colors.blueGrey),
    ];
    loanedOut = [
      Loan(
          assetName: 'لپ‌تاپ Dell XPS 15',
          personName: l10n.loanTo + ' آقای رضایی',
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
          assetIcon: Icons.laptop_mac_outlined,
          itemColor: Colors.blueGrey),
      Loan(
          assetName: 'دریل شارژی Bosch',
          personName: l10n.loanTo + ' واحد تاسیسات',
          dueDate: DateTime.now().add(const Duration(days: 25)),
          assetIcon: Icons.build_circle_outlined,
          itemColor: Colors.blueGrey)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final primaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final scaffoldBackgroundColor =
    isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);

    final appbarColors =  Colors.blueGrey;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.loanDashboardTitle,
          style: GoogleFonts.poppins(
              color: primaryTextColor, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            _buildSectionHeader(context, l10n.myLoansTab),
            ...myLoans.map((loan) =>
                _LoanListItemCard(loan: loan, isDarkMode: isDarkMode)
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.2)),
            SizedBox(height: 4.h),
            _buildSectionHeader(context, l10n.loanedOutTab),
            ...loanedOut.map((loan) =>
                _LoanListItemCard(loan: loan, isDarkMode: isDarkMode)
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.2)),
          ],
        ),
      ),
        floatingActionButton: SpeedDial(
          backgroundColor: scaffoldBackgroundColor,
          icon: Icons.menu,
          activeIcon: Icons.close,
          spacing: 12,
          spaceBetweenChildren: 8,
          children: [
            SpeedDialChild(
              child: Icon(Icons.qr_code_2),
              label: l10n.receiveLoanFAB,
              onTap: () => context.push('/receive_loan'),
            ),
            SpeedDialChild(
              child: Icon(Icons.add),
              label: l10n.giveLoanFAB,
              onTap: () => context.push('/create_loan'),
            ),
          ],
        ).animate().slideY(begin: 2, duration: 500.ms, curve: Curves.easeInOut),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _LoanListItemCard extends StatelessWidget {
  final Loan loan;
  final bool isDarkMode;

  const _LoanListItemCard({required this.loan, required this.isDarkMode});


  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cardColor =
    isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final primaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;
    final isOverdue = loan.dueDate.isBefore(DateTime.now());
    final textColors = isDarkMode ? Colors.white : Colors.black;
    return Card(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 4.w,
                  backgroundColor: loan.itemColor.withOpacity(0.15),
                  child: Icon(loan.assetIcon, color: loan.itemColor, size: 5.w),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    loan.assetName,
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              loan.personName,
              style: GoogleFonts.poppins(
                  fontSize: 11.sp, color: secondaryTextColor),
            ),
            Divider(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.returnDate,
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp, color: secondaryTextColor)),
                    Text(DateFormat('yyyy/MM/dd').format(loan.dueDate),
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor)),
                  ],
                ),
                if (isOverdue)
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(l10n.overdue,
                        style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w600)),
                  )
                else
                  OutlinedButton(
                      onPressed: () {}, child: Text(l10n.returnAssetButton,style: TextStyle(color: textColors),))
              ],
            ),
          ],
        ),
      ),
    );
  }
}