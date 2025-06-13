import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kipost/app_route.dart';
import 'package:kipost/models/user.dart';

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

  Future<void> register(String email, String password, String name, bool isClient, bool isProvider) async {
    // Create user with Firebase Auth
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Create user profile in Firestore
    if (userCredential.user != null) {
      final user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        isClient: isClient,
        isProvider: isProvider,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toMap());
    }
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

  // Get current user profile from Firestore
  Future<UserModel?> getCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update(updatedUser.copyWith(updatedAt: DateTime.now()).toMap());
  }
}