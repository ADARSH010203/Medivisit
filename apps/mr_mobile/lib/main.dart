import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mr_mobile/l10n/generated/app_localizations.dart';
import 'package:core/core.dart';

import 'package:firebase_app_check/firebase_app_check.dart';

import '../firebase_options.dart';
import 'app/bindings.dart';
import 'app/routes.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      
      final syncService = OfflineSyncService();
      Get.put<OfflineSyncService>(syncService);
      
      Get.put<ExpenseRepository>(FirebaseExpenseRepository());
      Get.put<VisitRepository>(FirebaseVisitRepository());
      Get.put<AttendanceRepository>(FirebaseAttendanceRepository());
      Get.put<LeaveRepository>(FirebaseLeaveRepository());
      
      await syncService.init();
      await syncService.flushOutbox();
      
      return Future.value(true);
    } catch (err) {
      debugPrint('Background task failed: $err');
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Change to playIntegrity in prod
    appleProvider: AppleProvider.debug, // Change to deviceCheck in prod
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
  );

  if (!kIsWeb) {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }
  
  Get.put(SupabaseFunctionService());
  await Get.putAsync(() => OfflineSyncService().init());
  await Get.putAsync(() => BackgroundSyncService().init());
  
  Get.put<BadgeRepository>(FirebaseBadgeRepository());
  Get.put<TrackingRepository>(FirebaseTrackingRepository());
  Get.put<ExpenseRepository>(FirebaseExpenseRepository());
  
  // Services (AuthService registered in InitialBinding)
  Get.put(OcrService());
  
  await Supabase.initialize(
    url: 'https://wrjxzzdqrbytufdpbeyo.supabase.co',
    publishableKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indyanh6emRxcmJ5dHVmZHBiZXlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA2NjU0MzUsImV4cCI6MjA1NjI0MTQzNX0.PlaceholderAnonKey',
    ),
  );

  runApp(const MediVisitProApp());
}

class MediVisitProApp extends StatelessWidget {
  const MediVisitProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MediVisit Pro',
      theme: buildMobileTheme(false),
      darkTheme: buildMobileTheme(true),
      themeMode: ThemeMode.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
    );
  }
}
