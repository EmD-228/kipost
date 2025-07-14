import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:kipost/app_route.dart';
import 'package:kipost/controllers/announcement_controller.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/controllers/calendar_controller.dart';
import 'package:kipost/controllers/notification_controller.dart';
import 'package:kipost/controllers/work_controller.dart';
import 'package:kipost/firebase_options.dart';
import 'package:kipost/screens/auth/auth_screen.dart';
import 'package:kipost/theme/app_theme.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialisation des contrôleurs
    Get.put(AuthController());
     Get.put(WorkController());
    Get.put(AnnouncementController());
    Get.put(ProposalController());
    Get.put(CalendarController());
    Get.put(NotificationController());
    



    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kipost',
      locale: const Locale('fr', 'FR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      getPages: AppRoutes.routes,
      // Page d'accueil initiale - AuthController se charge de la navigation
      home: const AuthScreen(),
    );
  }
}

