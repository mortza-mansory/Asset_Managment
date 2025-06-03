import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'core/di/app_providers.dart';
import 'core/routes/app_router.dart';

void main() {
  runApp(const AssetManagerApp());
}

class AssetManagerApp extends StatelessWidget {
  const AssetManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: AppProviders.providers(),
          child: MaterialApp.router(
            title: 'AssetManagerRfid',
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
          ),
        );
      },
    );
  }
}
