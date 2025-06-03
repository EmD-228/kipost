import 'package:get/get.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/auth_welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/announcement/create_announcement_screen.dart';
import 'screens/announcement/announcement_list_screen.dart';
import 'screens/announcement/announcement_detail_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String auth = '/auth';
  static const String authWelcome = '/auth-welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String createAnnouncement = '/create-announcement';
  static const String announcementList = '/announcement-list';
  static const String announcementDetail = '/announcement-detail';

  static final routes = [
    GetPage(name: home, page: () => const MyHomePage(title: 'Kipost Home')),
    GetPage(name: auth, page: () => const AuthScreen()),
    GetPage(name: authWelcome, page: () => const AuthWelcomeScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: createAnnouncement, page: () => const CreateAnnouncementScreen()),
    GetPage(name: announcementList, page: () => AnnouncementListScreen()),
    GetPage(name: announcementDetail, page: () => const AnnouncementDetailScreen()),
  ];
}