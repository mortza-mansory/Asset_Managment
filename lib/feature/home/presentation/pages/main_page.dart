// lib/feature/home/presentation/pages/main_page.dart

import 'package:assetsrfid/feature/assets_explore/presentation/page/asset_explore_page.dart';
import 'package:assetsrfid/feature/assets_explore/presentation/page/search_page.dart';
import 'package:assetsrfid/feature/assets_loan_management/presentation/pages/asset_loan_dashboard_page.dart';
import 'package:assetsrfid/feature/home/presentation/pages/home_page.dart';
import 'package:assetsrfid/feature/navbar/presentation/bloc/nav_bar_event.dart';
import 'package:assetsrfid/feature/profile/persantation/page/profile_page.dart';
import 'package:assetsrfid/feature/rfid/presentation/pages/rfid_scanner_page.dart';
import 'package:assetsrfid/shared/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:get_it/get_it.dart'; // Import GetIt

import '../../../navbar/presentation/bloc/nav_bar_bloc.dart';
import '../../../navbar/presentation/bloc/nav_bar_state.dart';
import '../../../asset_managment/presentation/bloc/assets_management/asset_managment_bloc.dart'; // Import AssetManagmentBloc
import '../../../../core/services/session_service.dart'; // Import SessionService

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final double navBarHeight = 6.h > 50 ? 50 : 6.h;
  late final SessionService _sessionService; // Declare SessionService

  final List<Widget> _pages = [
    const HomePage(),
    const RfidScanPage(),
    const AssetExplorePage(),
    const AssetLoanDashboardPage(),
    const ProfilePage(canHide: true),
  ];

  @override
  void initState() {
    super.initState();
    _sessionService = GetIt.instance<SessionService>(); // Initialize SessionService

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetManagmentBloc>().setContext(context);

      final activeCompany = _sessionService.getActiveCompany();
      if (activeCompany != null && activeCompany.id != null) {
        final int companyId = activeCompany.id;
        context.read<AssetManagmentBloc>().add(CheckAssetsAndNavigateIfNeeded(companyId: companyId));
      } else {
        print('Warning: Active company not found or companyId is null. Cannot check assets for bulk upload.');
        // Optionally, navigate to a company selection/creation page if this is a critical dependency
        // context.go('/company_selection_page');
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.read<NavBarBloc>().add(ResetNavBar());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetManagmentBloc, AssetManagmentState>(
      listener: (context, state) {
        // This listener can be used for showing general errors if navigation doesn't occur,
        // or for other UI feedback related to asset management state.
        if (state is AssetManagmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        // Navigation to /bulk_upload_guidance is handled directly within AssetManagmentBloc
        // when assets are found to be empty.
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            BlocBuilder<NavBarBloc, NavBarState>(
              builder: (context, state) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: state is NavBarVisible ? 0 : -0.96 * navBarHeight,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: CustomFloatingNavBar(
                      selectedIndex: _selectedIndex,
                      onItemTapped: _onItemTapped,
                      canHide: true,
                      navBarHeight: navBarHeight,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}