import 'package:assetsrfid/core/di/app_providers.dart';
import 'package:assetsrfid/core/routes/app_router.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_bloc.dart';
import 'package:assetsrfid/feature/localization/presentation/bloc/localization_state.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_bloc.dart';
import 'package:assetsrfid/feature/theme/bloc/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  setupDependencies();
  runApp(const AssetManagerApp());
}

class AssetManagerApp extends StatelessWidget {
  const AssetManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        // ✨ Use MultiProvider to provide all BLoCs globally.
        return MultiProvider(
          providers: AppProviders.providers(),
          child: BlocBuilder<LocalizationBloc, LocalizationState>(
            builder: (context, localizationState) {
              return BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return MaterialApp.router(
                    title: 'AssetManagerRfid',
                    debugShowCheckedModeBanner: false,
                    routerConfig: AppRouter.router,
                    theme: ThemeData.light(), // Your light theme
                    darkTheme: ThemeData.dark(),   // Your dark theme
                    themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                    locale: localizationState.locale,
                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}