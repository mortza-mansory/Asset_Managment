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

extension SnackbarExtensions on BuildContext {
  void showSnackBar(String message, {Color? backgroundColor, Color? textColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? Theme.of(this).snackBarTheme.backgroundColor,
        behavior: SnackBarBehavior.floating, // ظاهر شناور
        // duration: const Duration(seconds: 3), // مدت نمایش
      ),
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: this,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}