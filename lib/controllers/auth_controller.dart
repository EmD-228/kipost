import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kipost/app_route.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();
  final Rxn<User> firebaseUser = Rxn<User>();
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    // Écouter les changements d'état d'authentification
    firebaseUser.bindStream(FirebaseAuth.instance.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
    super.onInit();
  }

  void _setInitialScreen(User? user) {
    // Petit délai pour éviter les conflits de navigation
    Future.delayed(const Duration(milliseconds: 100), () {
      isLoading.value = false;
      if (user == null) {
        Get.offAllNamed(AppRoutes.authWelcome);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    });
  }

  Future<void> register(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}