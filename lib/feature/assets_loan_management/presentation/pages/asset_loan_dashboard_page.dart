import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/asset_loan_dashboard/asset_loan_dashboard_bloc.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/asset_loan_dashboard/asset_loan_dashboard_event.dart'; // Ensure this import is present
import 'package:assetsrfid/feature/assets_loan_management/presentation/bloc/asset_loan_dashboard/asset_loan_dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:intl/intl.dart';
import 'package:assetsrfid/feature/assets_loan_management/domain/entities/loan_entity.dart';

class AssetLoanDashboardPage extends StatefulWidget {
  const AssetLoanDashboardPage({super.key});

  @override
  State<AssetLoanDashboardPage> createState() => _AssetLoanDashboardPageState();
}

class _AssetLoanDashboardPageState extends State<AssetLoanDashboardPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Correct way to dispatch an event to the BLoC
    context.read<AssetLoanDashboardBloc>().add(LoadLoans());
  }

  void _showActionModal(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.read<ThemeBloc>().state.isDarkMode; // استفاده از read به جای watch
    final modalBackgroundColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        backgroundColor: modalBackgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectAction,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: Icon(Icons.qr_code_2, color: textColor, size: 6.w),
                title: Text(
                  l10n.receiveLoanFAB,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: textColor),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/receive_loan');
                },
              ),
              ListTile(
                leading: Icon(Icons.add, color: textColor, size: 6.w),
                title: Text(
                  l10n.giveLoanFAB,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: textColor),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/create_loan');
                },
              ),
              SizedBox(height: 1.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.cancel,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);
    final appBarBackgroundColor = isDarkMode ? const Color(0xFF202124) : const Color(0xFF37474F);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        title: Text(
          l10n.loansManagement,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Material(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(20.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.0),
                onTap: () => _showActionModal(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  child: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AssetLoanDashboardBloc, AssetLoanDashboardState>(
        listener: (context, state) {
          // Corrected: Use AssetLoanDashboardError state name
          if (state is AssetLoanDashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? l10n.unknownError)),
            );
          } else if (state is LoanReturnSuccess) {
            // Corrected: Convert loanId to String for localization
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.loanReturnedSuccessfully(state.loanId.toString()))),
            );
          }
        },
        builder: (context, state) {
          // Corrected: Use AssetLoanDashboardLoading and AssetLoanDashboardLoaded state names
          if (state is AssetLoanDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AssetLoanDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AssetLoanDashboardBloc>().add(LoadLoans());
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    _buildSectionHeader(context, l10n.myLoansTab),
                    if (state.myLoans.isEmpty)
                      _buildEmptyState(l10n.noMyLoans)
                    else
                      ...state.myLoans.map((loan) => _LoanListItemCard(
                          loan: loan, isDarkMode: isDarkMode, l10n: l10n)
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: 0.2)),
                    SizedBox(height: 4.h),
                    _buildSectionHeader(context, l10n.loanedOutTab),
                    if (state.loanedOutAssets.isEmpty)
                      _buildEmptyState(l10n.noLoanedOutAssets)
                    else
                      ...state.loanedOutAssets.map((loan) => _LoanListItemCard(
                          loan: loan, isDarkMode: isDarkMode, l10n: l10n)
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.2)),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            );
          }
          // Corrected: Use AssetLoanDashboardError state name for the final error display
          else if (state is AssetLoanDashboardError) {
            return Center(
                child: Text('خطا: ${state.message ?? l10n.unknownError}',
                    style: TextStyle(color: primaryTextColor)));
          }
          return Center(
              child: Text(l10n.loadLoansInitialText,
                  style: TextStyle(color: primaryTextColor)));
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final primaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.9)
        : Colors.black87;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: primaryTextColor.withOpacity(0.7)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _LoanListItemCard extends StatelessWidget {
  final LoanEntity loan;
  final bool isDarkMode;
  final l10n;

  const _LoanListItemCard({required this.loan, required this.isDarkMode, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600;
    final textColors = isDarkMode ? Colors.white : Colors.black;

    final isOverdue = loan.isOverdue;
    final IconData assetIcon = Icons.inventory_2_outlined;

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
                  backgroundColor: Colors.blueGrey.withOpacity(0.15),
                  child: Icon(assetIcon, color: Colors.blueGrey, size: 5.w),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    loan.assetName,
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp, fontWeight: FontWeight.w600, color: primaryTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            // Corrected: Provide a default non-nullable String if both externalRecipient and recipientName are null
            Text(
              loan.externalRecipient ?? loan.recipientName ?? l10n.unknownRecipient,
              style: GoogleFonts.poppins(fontSize: 11.sp, color: secondaryTextColor),
            ),
            if (loan.phoneNumber != null && loan.phoneNumber!.isNotEmpty) // New: Display phone number if available
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${l10n.phoneNumberLabel}: ${loan.phoneNumber}', // Assuming you add phoneNumberLabel to l10n
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: secondaryTextColor),
                ),
              ),
            Divider(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.returnDate,
                        style: GoogleFonts.poppins(fontSize: 10.sp, color: secondaryTextColor)),
                    Text(
                        loan.endDate != null
                            ? DateFormat('yyyy/MM/dd').format(loan.endDate!)
                            : l10n.noReturnDate,
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, fontWeight: FontWeight.bold, color: primaryTextColor)),
                  ],
                ),
                if (isOverdue)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(l10n.overdue,
                        style: GoogleFonts.poppins(
                            fontSize: 12.sp, color: Colors.red.shade400, fontWeight: FontWeight.w600)),
                  )
                else
                  OutlinedButton(
                      onPressed: () {
                        // Correct way to dispatch an event to the BLoC
                        context.read<AssetLoanDashboardBloc>().add(ReturnLoanEvent(loan.id));
                      },
                      child: Text(l10n.returnAssetButton, style: TextStyle(color: textColors))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}