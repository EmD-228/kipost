import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:kipost/app_route.dart';
import 'package:kipost/controllers/annoncement_controller.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/firebase_options.dart';
import 'package:kipost/screens/auth/auth_screen.dart';
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
    Get.put(AnnouncementController());
    Get.put(ProposalController());



    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kipost',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      getPages: AppRoutes.routes,
      // Page d'accueil initiale - AuthController se charge de la navigation
      home: const AuthScreen(),
    );
  }
}

