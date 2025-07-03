import 'package:assetsrfid/feature/asset_managment/presentation/pages/asset_list_page.dart';
import 'package:assetsrfid/feature/home/presentation/pages/home_page.dart';
import 'package:assetsrfid/feature/navbar/presentation/bloc/nav_bar_event.dart';
import 'package:assetsrfid/feature/profile/persantation/page/profile_page.dart';
import 'package:assetsrfid/feature/rfid/presentation/pages/rfid_scanner_page.dart';
import 'package:assetsrfid/feature/search/presentation/page/search_page.dart';
import 'package:assetsrfid/shared/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../navbar/presentation/bloc/nav_bar_bloc.dart';
import '../../../navbar/presentation/bloc/nav_bar_state.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final double navBarHeight = 6.h > 50 ? 50 : 6.h;

  final List<Widget> _pages = [
    const HomePage(),
    const RfidScanPage(),
    const AssetListPage(),
    const SearchPage(),
    const ProfilePage(canHide: true),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.read<NavBarBloc>().add(ResetNavBar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}