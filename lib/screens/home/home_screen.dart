import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/components/home/jobs_tab.dart';
import 'package:kipost/components/home/proposals_tab.dart';
import 'package:kipost/components/home/profile_tab.dart';
import 'package:kipost/components/home/feature_tabs.dart';
import 'package:kipost/components/home/nav_icon.dart';
import 'package:kipost/components/text/app_text.dart';
import 'package:kipost/controllers/notification_controller.dart';
import 'package:kipost/app_route.dart';
import 'package:kipost/theme/app_colors.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedTab() {
    switch (_selectedIndex) {
      case 0:
        return const JobsTab();
      case 1:
        return const ProposalsTab();
      case 2:
        return const CalendrierTab();
      case 3:
        return const ProfileTab();
      default:
        return const JobsTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black26,
        toolbarHeight: 70,
        title: Row(
          children: [
            AppText.heading1(
              "kipost",
              color: AppColors.primary,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),

            const Spacer(),
            // Icône de notification avec compteur
            Obx(() {
              final notificationController = Get.find<NotificationController>();
              final unreadCount = notificationController.unreadCount;

              return GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.notifications),
                child: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.red,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.notification,
                      color: AppColors.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      body: _getSelectedTab(),
      floatingActionButton:
          _selectedIndex == 0
              ? Container(
                decoration: BoxDecoration(
                  color:AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Icon(Iconsax.add, color: Colors.white, size: 28),
                  onPressed: () => Get.toNamed('/create-announcement'),
                ),
              )
              : _selectedIndex == 2
              ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.orange.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Icon(
                    Iconsax.calendar_add,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    // TODO: Implémenter l'ajout d'événement
                    Get.snackbar(
                      'Calendrier',
                      'Fonctionnalité d\'ajout d\'événement à venir',
                      backgroundColor: Colors.orange.shade100,
                      colorText: Colors.orange.shade800,
                    );
                  },
                ),
              )
              : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor:AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedIconTheme: Get.theme.iconTheme.copyWith(
            color: AppColors.primary,
          ),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: NavIcon(
                icon: Iconsax.briefcase,
                index: 0,
                selectedIndex: _selectedIndex,
              ),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: NavIcon(
                icon: Iconsax.note_2,
                index: 1,
                selectedIndex: _selectedIndex,
              ),
              label: 'Propositions',
            ),
            BottomNavigationBarItem(
              icon: NavIcon(
                icon: Iconsax.calendar,
                index: 2,
                selectedIndex: _selectedIndex,
              ),
              label: 'Calendrier',
            ),
            BottomNavigationBarItem(
              icon: NavIcon(
                icon: Iconsax.user,
                index: 3,
                selectedIndex: _selectedIndex,
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
