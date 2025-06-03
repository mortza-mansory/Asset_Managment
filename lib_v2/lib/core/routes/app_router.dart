import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_state.dart';
import 'package:assetsrfid/feature/asset_managment/presentation/pages/home_page.dart';
import 'package:assetsrfid/feature/rfid/presentation/pages/rfid_scanner_page.dart';
import 'package:assetsrfid/feature/search/presentation/page/search_page.dart';
import 'package:assetsrfid/feature/profile/persantation/page/profile_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/login_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/modal_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/otp_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/sign_up_page.dart';
import 'package:assetsrfid/feature/auth/presentation/pages/splash_page.dart';
import 'package:assetsrfid/shared/widgets/custom_bottom_navbar.dart';

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
      ShellRoute(
        pageBuilder: (context, state, child) {
          final List<NavItem> navBarItems = [
            NavItem(
                icon: Icons.home_filled, text: 'خانه', tooltip: 'صفحه اصلی'),
            NavItem(
                icon: Icons.document_scanner_outlined,
                text: 'RFID اسکن',
                tooltip: 'اسکن RFID'),
            NavItem(
                icon: Icons.search, text: 'جستجو', tooltip: 'جستجوی دارایی‌ها'),
            NavItem(
                icon: Icons.account_circle_outlined,
                text: 'حساب',
                tooltip: 'تنظیمات کاربری'),
          ];

          int getSelectedIndex(String location) {
            if (location == '/home') return 0;
            if (location == '/rfid_scan') return 1;
            if (location == '/search_page') return 2;
            if (location == '/profile_page') return 3;
            return 0;
          }

          return NoTransitionPage(
            child: Scaffold(
              body: Stack(
                children: [
                  child,
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: CustomFloatingNavBar(
                      selectedIndex: getSelectedIndex(state.uri.toString()),
                      onItemTapped: (index) {
                        if (index == 0) {
                          context.go('/home');
                        } else if (index == 1) {
                          context.go('/rfid_scan');
                        } else if (index == 2) {
                          context.go('/search_page');
                        } else if (index == 3) {
                          context.go('/profile_page');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/rfid_scan',
            builder: (context, state) => const RfidScanPage(),
          ),
          GoRoute(
            path: '/search_page',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: '/profile_page',
            builder: (context, state) => const UserProfilePage(),
          ),
        ],
      ),
    ],
  );
}
