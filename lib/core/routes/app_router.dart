import 'package:assetsrfid/feature/about/presentation/page/about_page.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/pages/asset_detail_edit_page.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/pages/asset_detail_page.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/pages/asset_history_page.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/pages/asset_list_page.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/pages/asset_loan_dashboard_page.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/pages/create_loan_page.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/pages/receive_loan_page.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/pages/scan_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/forgot_password_page.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/page/company_settings_page.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/page/create_company_page.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/page/my_companies_page.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/page/onboarding_complete_page.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/page/role_selection_page.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/page/switch_company_page.dart';
import 'package:assetsrfid/feature/goverment_management/presentation/page/update_company_page.dart';
import 'package:assetsrfid/feature/home/presentation/pages/home_page.dart';
import 'package:assetsrfid/feature/home/presentation/pages/main_page.dart';
import 'package:assetsrfid/feature/profile/persantation/page/profile_page.dart';
import 'package:assetsrfid/feature/reports/presentation/page/recent_activity_page.dart';
import 'package:assetsrfid/feature/reports/presentation/page/reports_page.dart';
import 'package:assetsrfid/feature/reports/presentation/page/workflow_page.dart';
import 'package:assetsrfid/feature/rfid/presentation/pages/rfid_validation_page.dart';
import 'package:assetsrfid/feature/search/presentation/page/search_page.dart';
import 'package:go_router/go_router.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/login_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/modal_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/otp_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/sign_up_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/splash_page.dart';
import 'package:assetsrfid/feature/subscription/presentation/pages/buy_subscription_page.dart';
import 'package:assetsrfid/feature/subscription/presentation/pages/check_subscription_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/otp/:tempToken',
        builder: (context, state) {
          final tempToken = state.pathParameters['tempToken'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final userId = extra['userId'] as int? ?? 0;
          final isForLogin = extra['isForLogin'] as bool? ?? false;

          return OtpPage(
            tempToken: tempToken,
            userId: userId,
          );
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/modal_start',
        builder: (context, state) => const ModalPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainPage(),
      ),
      GoRoute(
        path: '/search_assets',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: '/workflow',
        builder: (context, state) => const WorkflowPage(),
      ),
      GoRoute(
        path: '/recent_activity',
        builder: (context, state) => const RecentActivityPage(),
      ),
      GoRoute(
        path: '/assets_list',
        builder: (context, state) => const AssetListPage(),
      ),
      GoRoute(
        path: '/assets_detail',
        builder: (context, state) => const AssetDetailPage(),
      ),
      GoRoute(
        path: '/asset_detail_edit',
        builder: (context, state) => const AssetDetailEditPage(),
      ),
      GoRoute(
        path: '/asset_history',
        builder: (context, state) => const AssetHistoryPage(),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/rfid_validation/:state',
        builder: (context, state) {
          //   int validationState = int.tryParse(state.pathParameters['state'] ?? '2') ?? 1;
          return RfidValidationPage(
            state: 1,
          );
        },
      ),
      GoRoute(
        path: '/buy_subscription',
        builder: (context, state) => const BuySubscriptionPage(),
      ),
      GoRoute(
        path: '/check_subscription',
        name: 'check_subscription',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          print('Navigated to /check_subscription with params: $params');
          return CheckSubscriptionPage(
            purchaseUrl: params['url']!,
            subscriptionId: int.parse(params['id']!),
          );
        },
      ),
      // GoRoute(
      //   path: '/check_subscription',
      //   name: 'check_subscription',
      //   builder: (context, state) {
      //     final url = state.uri.queryParameters['url'] ?? '';
      //     final subIdString = state.uri.queryParameters['id'] ?? '0';
      //     final subId = int.tryParse(subIdString) ?? 0;
      //
      //     return CheckSubscriptionPage(
      //       purchaseUrl: url,
      //       subscriptionId: subId,
      //     );
      //   },
      // ),
      GoRoute(
          path: '/role_selection',
          builder: (context, state) => const RoleSelectionPage()),
      GoRoute(
          path: '/my_companies',
          builder: (context, state) => const MyCompaniesPage()),
      GoRoute(
          path: '/create_company',
          builder: (context, state) => const CreateCompanyPage()),
      GoRoute(
          path: '/onboarding_complete',
          builder: (context, state) => const OnboardingCompletePage()),
      GoRoute(
        path: '/switch_company',
        builder: (context, state) => const SwitchCompanyPage(),
      ),
      GoRoute(
        path: '/loans',
        builder: (context, state) => const AssetLoanDashboardPage(),
      ),
      GoRoute(
        path: '/create_loan',
        builder: (context, state) => const CreateLoanPage(),
      ),
      GoRoute(
        path: '/receive_loan',
        builder: (context, state) => const ReceiveLoanPage(),
      ),
      GoRoute(
        path: '/scan_page/:mode',
        builder: (context, state) {
          final modeString = state.pathParameters['mode'] ?? 'rfid';
          final scanMode = modeString == 'qrcode' ? ScanMode.qrCode : ScanMode.rfid;
          return ScanPage(mode: scanMode);
        },
      ),
      GoRoute(
        path: '/companies/update',
        builder: (context, state) {
          final company = state.extra as CompanyMembership;
          return UpdateCompanyPage(company: company);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/company-settings',
        builder: (context, state) => const CompanySettingsPage(),
      ),
      GoRoute(
        path: '/about-app',
        builder: (context, state) => const AboutPage(),
      ),
    ],
  );
}
