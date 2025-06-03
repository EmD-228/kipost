import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/controllers/annoncement_controller.dart';
import 'package:kipost/controllers/auth_controller.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/models/announcement.dart';
import 'package:kipost/models/proposal.dart';
import 'package:kipost/components/announcement_card.dart';
import 'package:kipost/components/proposal_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final AnnouncementController controller = Get.find();
  final ProposalController proposalController = Get.put(ProposalController());

  final List<String> _categories = [
    'Toutes', 'Menuiserie', 'Plomberie', 'Électricité', 'Aide ménagère', 'Transport', 'Autre',
  ];
  String _selectedCategory = 'Toutes';

  final List<String> _statusList = ['Tous', 'ouverte', 'fermée'];
  String _selectedStatus = 'Tous';

  final List<String> _dateSortList = ['Plus récentes', 'Plus anciennes'];
  String _selectedDateSort = 'Plus récentes';

  String _search = '';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildJobsTab() {
    return Column(
      children: [
        // Barre de recherche moderne
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => setState(() => _search = val),
              decoration: InputDecoration(
                hintText: "Rechercher un service, une annonce...",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Iconsax.search_normal, color: Colors.deepPurple, size: 20),
                ),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: Icon(Iconsax.close_circle, color: Colors.grey.shade400),
                        onPressed: () => setState(() => _search = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.3), width: 2),
                ),
              ),
            ),
          ),
        ),
        // Filtres horizontaux modernisés
        Container(
          height: 60,
          margin: const EdgeInsets.only(top: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ..._categories.map((cat) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.deepPurple.shade50,
                  checkmarkColor: Colors.deepPurple,
                  labelStyle: TextStyle(
                    color: _selectedCategory == cat ? Colors.deepPurple : Colors.grey.shade700,
                    fontWeight: _selectedCategory == cat ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedCategory == cat 
                          ? Colors.deepPurple.withOpacity(0.3)
                          : Colors.grey.shade300,
                    ),
                  ),
                  elevation: _selectedCategory == cat ? 2 : 0,
                  pressElevation: 4,
                ),
              )),
              const SizedBox(width: 12),
              ..._statusList.map((status) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(status),
                  selected: _selectedStatus == status,
                  onSelected: (_) => setState(() => _selectedStatus = status),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.deepPurple.shade50,
                  checkmarkColor: Colors.deepPurple,
                  labelStyle: TextStyle(
                    color: _selectedStatus == status ? Colors.deepPurple : Colors.grey.shade700,
                    fontWeight: _selectedStatus == status ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedStatus == status 
                          ? Colors.deepPurple.withOpacity(0.3)
                          : Colors.grey.shade300,
                    ),
                  ),
                  elevation: _selectedStatus == status ? 2 : 0,
                  pressElevation: 4,
                ),
              )),
              const SizedBox(width: 12),
              ..._dateSortList.map((sort) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(sort),
                  selected: _selectedDateSort == sort,
                  onSelected: (_) => setState(() => _selectedDateSort = sort),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.deepPurple.shade50,
                  checkmarkColor: Colors.deepPurple,
                  labelStyle: TextStyle(
                    color: _selectedDateSort == sort ? Colors.deepPurple : Colors.grey.shade700,
                    fontWeight: _selectedDateSort == sort ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedDateSort == sort 
                          ? Colors.deepPurple.withOpacity(0.3)
                          : Colors.grey.shade300,
                    ),
                  ),
                  elevation: _selectedDateSort == sort ? 2 : 0,
                  pressElevation: 4,
                ),
              )),
            ],
          ),
        ),
        // Liste des annonces
        Expanded(
          child: StreamBuilder(
            stream: controller.getAnnouncementsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.briefcase,
                            size: 80,
                            color: Colors.deepPurple.shade300,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Aucune annonce disponible',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Soyez le premier à créer une annonce\net trouvez le service parfait !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: KipostButton(
                            label: 'Créer une annonce',
                            icon: Iconsax.add,
                            onPressed: () => Get.toNamed('/create-announcement'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // Filtrage par catégorie, statut, recherche
              var docs = snapshot.data!.docs.where((doc) {
                final catOk = _selectedCategory == 'Toutes' || doc['category'] == _selectedCategory;
                final statusOk = _selectedStatus == 'Tous' || doc['status'] == _selectedStatus;
                final searchOk = _search.isEmpty ||
                    (doc['title'] ?? '').toLowerCase().contains(_search.toLowerCase()) ||
                    (doc['description'] ?? '').toLowerCase().contains(_search.toLowerCase());
                return catOk && statusOk && searchOk;
              }).toList();

              // Conversion en objets Announcement
              final announcements = docs
                  .map((doc) => Announcement.fromMap(doc.data(), doc.id))
                  .toList();

              // Tri par date
              announcements.sort((a, b) {
                if (_selectedDateSort == 'Plus récentes') {
                  return b.createdAt.compareTo(a.createdAt);
                } else {
                  return a.createdAt.compareTo(b.createdAt);
                }
              });

              if (announcements.isEmpty) {
                return const Center(
                  child: Text('Aucune annonce pour ce filtre.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: announcements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final ann = announcements[i];
                  return AnnouncementCard(
                    announcement: ann,
                    onTap: () {
                      Get.toNamed('/announcement-detail', arguments: ann);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProposalsTab() {
    return StreamBuilder<List<Proposal>>(
      stream: proposalController.getUserProposalsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final proposals = snapshot.data ?? [];
        if (proposals.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.note_2,
                      size: 80,
                      color: Colors.deepPurple.shade300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aucune proposition',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vous n\'avez envoyé aucune proposition\npour le moment. Explorez les annonces\net proposez vos services !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _selectedIndex = 0),
                      icon: const Icon(Iconsax.briefcase, color: Colors.white),
                      label: const Text(
                        'Voir les annonces',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: proposals.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final prop = proposals[i];
            return ProposalCard(
              proposal: prop,
              onTap: () {
                // Navigation vers le détail de l'annonce liée à la proposition
                Get.toNamed('/announcement-detail', arguments: prop.announcementId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContractsTab() {
    return _buildComingSoonTab(
      icon: Iconsax.document,
      title: 'Contrats',
      description: 'Gérez vos contrats et suivez\nle statut de vos projets en cours.',
    );
  }

  Widget _buildMessagesTab() {
    return _buildComingSoonTab(
      icon: Iconsax.message,
      title: 'Messages',
      description: 'Communiquez directement avec\nvos clients et prestataires.',
    );
  }

  Widget _buildNotificationsTab() {
    return _buildComingSoonTab(
      icon: Iconsax.notification,
      title: 'Notifications',
      description: 'Restez informé des dernières\nactivités sur vos annonces.',
    );
  }

  Widget _buildComingSoonTab({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade50,
                    Colors.deepPurple.shade100,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 80,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.code,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Bientôt disponible',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_selectedIndex) {
      case 0:
        content = _buildJobsTab();
        break;
      case 1:
        content = _buildProposalsTab();
        break;
      case 2:
        content = _buildContractsTab();
        break;
      case 3:
        content = _buildMessagesTab();
        break;
      case 4:
        content = _buildNotificationsTab();
        break;
      default:
        content = _buildJobsTab();
    }

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
      body: content,
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
              icon: _buildNavIcon(Iconsax.briefcase, 0),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Iconsax.note_2, 1),
              label: 'Propositions',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Iconsax.document, 2),
              label: 'Contrats',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Iconsax.message, 3),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Iconsax.notification, 4),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
      ),
    );
  }
}

