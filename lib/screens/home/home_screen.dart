import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/controllers/auth_controller.dart';
import 'package:kipost/controllers/annoncement_controller.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/components/home/jobs_tab.dart';
import 'package:kipost/components/home/proposals_tab.dart';
import 'package:kipost/components/home/feature_tabs.dart';
import 'package:kipost/components/home/nav_icon.dart';

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
        return const ContractsTab();
      case 3:
        return const MessagesTab();
      case 4:
        return const NotificationsTab();
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Kipost",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.notification, color: Colors.deepPurple, size: 20),
            ),
            const SizedBox(width: 12),
            // Bouton temporaire pour la migration
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.setting_2, color: Colors.orange.shade600, size: 18),
              ),
              tooltip: 'Migration BD',
              onPressed: () => Get.toNamed('/migration'),
            ),
            const SizedBox(width: 8),
            // Bouton temporaire pour diagnostic et correction
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.health, color: Colors.blue.shade600, size: 18),
              ),
              tooltip: 'Diagnostic système',
              onPressed: () async {
                final announcementController = Get.find<AnnouncementController>();
                final proposalController = Get.find<ProposalController>();
                
                // Diagnostic du système
                await proposalController.diagnoseProposalSystem();
                
                // Correction des annonces sans proposalIds
                await announcementController.ensureProposalIdsField();
              },
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.user, color: Colors.deepPurple, size: 20),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.logout, color: Colors.red.shade600, size: 18),
              ),
              tooltip: 'Déconnexion',
              onPressed: () => AuthController.to.logout(),
            ),
          ],
        ),
      ),
      body: _getSelectedTab(),
      floatingActionButton: _selectedIndex == 0
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
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
                icon: Iconsax.document,
                index: 2,
                selectedIndex: _selectedIndex,
              ),
              label: 'Contrats',
            ),
            BottomNavigationBarItem(
              icon: NavIcon(
                icon: Iconsax.message,
                index: 3,
                selectedIndex: _selectedIndex,
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: NavIcon(
                icon: Iconsax.notification,
                index: 4,
                selectedIndex: _selectedIndex,
              ),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }
}

