import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:kipost/app_route.dart';
import 'package:kipost/controllers/annoncement_controller.dart';
import 'package:kipost/firebase_options.dart';
import 'controllers/auth_controller.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
      Get.put(AuthController());
      Get.put(AnnouncementController());


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kipost',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      getPages: AppRoutes.routes,
      initialRoute: AuthController.to.firebaseUser.value == null
          ? AppRoutes.auth
          : AppRoutes.home,
     
    );
  }
}

