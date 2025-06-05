import 'package:get/get.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/auth_welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/announcement/create_announcement_simple.dart';
// import 'screens/announcement/announcement_list_screen.dart';
import 'screens/announcement/announcement_detail_screen.dart';
import 'screens/announcement/proposals_screen.dart';
import 'screens/proposal/proposal_accepted_screen.dart';
import 'screens/debug_proposals_screen.dart';
import 'screens/migration_page.dart';
import 'screens/notifications/notifications_screen.dart';

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
  static const String proposals = '/proposals';
  static const String proposalAccepted = '/proposal-accepted';
  static const String debugProposals = '/debug-proposals';
  static const String migration = '/migration';
  static const String notifications = '/notifications';

  static final routes = [
    GetPage(name: home, page: () => const MyHomePage(title: 'Kipost Home')),
    GetPage(name: auth, page: () => const AuthScreen()),
    GetPage(name: authWelcome, page: () => const AuthWelcomeScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: createAnnouncement, page: () => const CreateAnnouncementSimpleScreen()),
    // GetPage(name: announcementList, page: () => AnnouncementListScreen()),
    GetPage(name: announcementDetail, page: () => const AnnouncementDetailScreen()),
    GetPage(name: proposals, page: () => const ProposalsScreen()),
    GetPage(name: proposalAccepted, page: () => ProposalAcceptedScreen(proposal: Get.arguments)),
    GetPage(name: debugProposals, page: () => const DebugProposalsScreen()),
    GetPage(name: migration, page: () => const MigrationPage()),
    GetPage(name: notifications, page: () => const NotificationsScreen()),
  ];
}