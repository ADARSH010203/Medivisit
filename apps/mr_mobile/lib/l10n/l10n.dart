import 'package:flutter/material.dart';
import 'package:mr_mobile/l10n/generated/app_localizations.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('hi'),
  ];
  
  static AppLocalizations tr(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
}
