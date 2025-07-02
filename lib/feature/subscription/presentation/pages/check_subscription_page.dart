import 'package:assetsrfid/core/utils/context_extensions.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_event.dart';
import 'package:assetsrfid/feature/subscription/presentation/bloc/subscription_state.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckSubscriptionPage extends StatelessWidget {
  final String purchaseUrl;
  final int subscriptionId;

  const CheckSubscriptionPage({
    super.key,
    required this.purchaseUrl,
    required this.subscriptionId,
  });

  Future<void> _launchUrl() async {
    final uri = Uri.parse(purchaseUrl);

    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _copyUrlToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: purchaseUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.linkCopiedSnackbar, style: GoogleFonts.poppins()),
      ),
    );
  }

  void _checkPaymentStatus(BuildContext context) {
    context
        .read<SubscriptionBloc>()
        .add(ConfirmPayment(subscriptionId: subscriptionId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDarkMode = context.watch<ThemeBloc>().state.isDarkMode;
    final primaryTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.87);
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final cardColor = isDarkMode ? const Color(0xFF2A2B2F) : Colors.white;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF1E1E20) : const Color(0xFFF4F6F8);

    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionActivated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.paymentSuccessfulSnackbar),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/create_company');
        } else if (state is SubscriptionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: scaffoldBackgroundColor,
          title:
          Text(l10n.checkSubscriptionTitle, style: GoogleFonts.poppins()),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop()),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.credit_card_outlined,
                  size: 25.w, color: Colors.blueGrey.shade300)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2),
              SizedBox(height: 3.h),
              Text(
                l10n.checkSubscriptionSubtitle,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp, color: secondaryTextColor, height: 1.5),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5.h),
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          purchaseUrl,
                          style: GoogleFonts.poppins(color: secondaryTextColor, fontSize: 10.sp),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_all_rounded),
                        tooltip: l10n.copyLinkButton,
                        onPressed: () => _copyUrlToClipboard(context),
                      )
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
              SizedBox(height: 2.h),
              NewCustomButton(
                text: l10n.openPaymentLink,
                backgroundColor: Colors.transparent,
                textColor: Theme.of(context).primaryColor,
                elevation: 0,
                onPressed: _launchUrl,
              ).animate().fadeIn(delay: 300.ms),
              const Spacer(flex: 2),
              BlocBuilder<SubscriptionBloc, SubscriptionState>(
                builder: (context, state) {
                  return NewCustomButton(
                    text: l10n.purchaseCompleteButton,
                    isLoading: state is SubscriptionLoading,
                    onPressed: () => _checkPaymentStatus(context),
                    backgroundColor: Colors.teal.shade600,
                  );
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}