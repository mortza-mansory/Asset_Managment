import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_event.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_state.dart';
import 'package:assetsrfid/shared/widgets/onboarding_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: 3,
      totalSteps: 5,
      body: BlocListener<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is UserSubscriptionStatus) {
            if (state.isActive) {
              context.go('/create_company');
            } else {
              context.go('/buy_subscription');
            }
          } else if (state is SubscriptionFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.roleSelectionTitle,
                style: GoogleFonts.poppins(
                    fontSize: 20.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                context.l10n.roleSelectionSubtitle,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              _buildChoiceCard(
                context: context,
                icon: Icons.business,
                title: context.l10n.myCompaniesButton,
                onTap: () {
                  context.go('/switch_company');
                },
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              SizedBox(height: 3.h),
              _buildChoiceCard(
                context: context,
                icon: Icons.add_business_outlined,
                title: context.l10n.createCompanyButton,
                onTap: () {
                  context
                      .read<SubscriptionBloc>()
                      .add(CheckCurrentUserSubscription());
                },
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
              SizedBox(height: 3.h),
              _buildChoiceCard(
                context: context,
                icon: Icons.groups_outlined,
                title: context.l10n.joinCompanyButton,
                onTap: () => context.go('/my_companies'),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard(
      {required BuildContext context,
      required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDarkMode ? Colors.blueGrey : Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 5.w),
          child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Row(
                children: [
                  Icon(icon,
                      size: 10.w,
                      color: isDarkMode
                          ? Colors.white70
                          : Colors.blueGrey.shade700),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.blueGrey.shade700),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: isDarkMode
                          ? Colors.white70
                          : Colors.blueGrey.shade700),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
