import 'package:assetsrfid/feature/asset_managment/presentation/pages/home_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/modal_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/otp_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/splash_page.dart';
import 'package:assetsrfid/feature/profile/persantation/page/profile_page.dart';
import 'package:assetsrfid/feature/rfid/presentation/pages/rfid_scanner_page.dart';
import 'package:assetsrfid/feature/search/presentation/page/search_page.dart';
import 'package:go_router/go_router.dart';

import '../../feature/auth/presentation/pages/login_page.dart';
import '../../feature/auth/presentation/pages/sign_up_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
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
      path: '/otp',
      builder: (context, state) => const OtpPage(tempToken: ""),
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
      builder: (context, state) =>  HomePage(),
    ),
    GoRoute(
      path: '/rfid_scan',
      builder: (context, state) =>  RfidScanPage(isDarkMode: false,),
    ),
    GoRoute(
      path: '/search_page',
      builder: (context, state) =>  SearchPage(isDarkMode: false,),
    ),
    GoRoute(
      path: '/profile_page',
      builder: (context, state) =>  UserProfilePage(isDarkMode: false,),
    ),
  ],
);
