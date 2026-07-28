import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:core/core.dart';

import 'package:firebase_app_check/firebase_app_check.dart';

import '../firebase_options.dart';
import 'app/bindings.dart';
import 'app/routes.dart';

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
  
  Get.put<NotificationRepository>(FirebaseNotificationRepository());
  Get.put<TrackingRepository>(FirebaseTrackingRepository());
  
  await Supabase.initialize(
    url: 'https://wrjxzzdqrbytufdpbeyo.supabase.co',
    publishableKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indyanh6emRxcmJ5dHVmZHBiZXlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA2NjU0MzUsImV4cCI6MjA1NjI0MTQzNX0.PlaceholderAnonKey',
    ),
  );

  await SeedDataService.seedDefaultAdmin();

  runApp(const MediVisitAdminApp());
}

class MediVisitAdminApp extends StatelessWidget {
  const MediVisitAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MediVisit Pro Admin',
      theme: buildAdminTheme(),
      themeMode: ThemeMode.dark, // Admin is always dark mode
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
    );
  }
}

