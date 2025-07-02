import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_event.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_state.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class BuySubscriptionPage extends StatelessWidget {
  const BuySubscriptionPage({super.key});

  Future<void> _launchUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('Successfully launched URL: $url');
      } else {
        print('Could not launch URL: $url');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open payment page, but proceeding to check subscription')),
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening payment page: $e, proceeding to check subscription')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
    isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.87);
    final secondaryTextColor =
    isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final scaffoldBackgroundColor =
    isDarkMode ? const Color(0xFF1A1B1E) : const Color(0xFFF8F9FA);

    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) async {
        print('Subscription state received: $state');
        if (state is SubscriptionLinkCreated) {
          print('SubscriptionLinkCreated: paymentUrl=${state.paymentUrl}, subscriptionId=${state.subscriptionId}');
          final params = <String, String>{
            'url': state.paymentUrl,
            'id': state.subscriptionId.toString(),
          };
          await _launchUrl(state.paymentUrl, context);
          // تأخیر 2 ثانیه‌ای
          await Future.delayed(const Duration(seconds: 2));
          print('Context mounted: ${context.mounted}');
          if (context.mounted) {
            print('Navigating to check_subscription with params: $params');
            try {
              context.pushNamed('check_subscription', queryParameters: params);
              print('Successfully navigated to check_subscription');
            } catch (e) {
              print('Navigation error: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Navigation error: $e')),
              );
            }
          } else {
            print('Context not mounted, cannot navigate');
          }
        } else if (state is SubscriptionFailure) {
          print('SubscriptionFailure: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Icon(Icons.workspace_premium_outlined,
                    size: 25.w, color: Colors.amber.shade600)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(delay: 200.ms, duration: 800.ms, curve: Curves.elasticOut),
                SizedBox(height: 4.h),
                Text(
                  l10n.buySubscriptionTitle,
                  style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                SizedBox(height: 1.5.h),
                Text(
                  l10n.buySubscriptionSubtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 12.5.sp,
                      color: secondaryTextColor,
                      height: 1.5),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
                const Spacer(flex: 3),
                TextButton(
                  onPressed: () => context.go('/main'),
                  child: Text(
                    l10n.testTheAppButton,
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500),
                  ),
                ).animate().fadeIn(delay: 800.ms),
                SizedBox(height: 1.h),
                BlocBuilder<SubscriptionBloc, SubscriptionState>(
                  builder: (context, state) {
                    return NewCustomButton(
                      text: l10n.buySubscriptionButton,
                      isLoading: state is SubscriptionLoading,
                      onPressed: () {
                        print('Buy button pressed, creating subscription');
                        context
                            .read<SubscriptionBloc>()
                            .add(CreateSubscription(planType: 'yearly'));
                      },
                      backgroundColor: Colors.teal.shade600,
                      elevation: 4,
                      animationDelay: 900.ms,
                    );
                  },
                ),
                SizedBox(height: 1.h),
                TextButton(
                  onPressed: () {
                    context.pushNamed('check_subscription',
                        queryParameters: {'url': 'test', 'id': '0'});
                    print('Manually navigated to check_subscription');
                  },
                  child: Text(
                    'Test Check Subscription',
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}