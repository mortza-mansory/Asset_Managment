import 'package:assetsrfid/core/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:assetsrfid/core/di/app_providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension AuthContext on BuildContext {

  bool can(String permissionKey) {
    return getIt<PermissionService>().can(permissionKey);
  }
}