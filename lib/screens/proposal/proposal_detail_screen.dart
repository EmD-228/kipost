import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:kipost/services/proposal_service.dart';
import 'package:kipost/services/announcement_service.dart';
import 'package:kipost/services/auth_service.dart';

class ProposalDetailScreen extends StatefulWidget {
  final ProposalModel proposal;
  final String? viewMode; // 'sent', 'received', 'accepted'

  const ProposalDetailScreen({
    super.key,
    required this.proposal,
    this.viewMode,
  });

  @override
  State<ProposalDetailScreen> createState() => _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends State<ProposalDetailScreen>
    with TickerProviderStateMixin {
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final ProposalService _proposalService = ProposalService();
  final AnnouncementService _announcementService = AnnouncementService();
  final AuthService _authService = AuthService();

  late ProposalModel currentProposal;
  AnnouncementModel? _announcement;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize currentProposal with the proposal passed in widget
    currentProposal = widget.proposal;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _loadAnnouncementData();
  }

  Future<void> _loadAnnouncementData() async {
    try {
      final announcement = await _announcementService.getAnnouncement(
        currentProposal.announcementId,
      );
      
      setState(() {
        _announcement = announcement;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading announcement: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isCurrentUserSender {
    final currentUser = _authService.currentUser;
    return currentUser?.id == currentProposal.providerId;
  }

  bool get _isCurrentUserReceiver {
    final currentUser = _authService.currentUser;
    return _announcement?.clientId == currentUser?.id;
  }

  String get _screenTitle {
    if (_isCurrentUserSender) {
      return 'Ma Proposition';
    } else if (_isCurrentUserReceiver) {
      return 'Proposition Reçue';
    }
    return 'Détail de la Proposition';
  }

  @override
  Widget build(BuildContext context) {
    printInfo(info: 'Current Proposal: ${currentProposal.toMap()}');
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _screenTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message de proposition
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Iconsax.message,
                                  color: Colors.blue.shade600,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Message de candidature',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentProposal.message,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            if (currentProposal.amount != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Iconsax.wallet,
                                      color: Colors.green.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Montant proposé: ${currentProposal.amount!.toStringAsFixed(0)} €',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Informations sur l'annonce
                      if (_announcement != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.task,
                                    color: Colors.orange.shade600,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Annonce concernée',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _announcement!.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _announcement!.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.category,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _announcement!.category,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (_announcement!.city != null) ...[
                                    Icon(
                                      Iconsax.location,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _announcement!.city!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (_announcement!.budget != null) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Iconsax.wallet,
                                      size: 16,
                                      color: Colors.green.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Budget: ${_announcement!.budget!.toStringAsFixed(0)} €',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Statut de la proposition
                      _buildStatusCard(),
                      const SizedBox(height: 20),

                      // Actions selon le statut
                      if (currentProposal.status == 'pending' && _isCurrentUserReceiver)
                        _buildReceiverActions(),
                      if (currentProposal.status == 'pending' && _isCurrentUserSender)
                        _buildSenderPendingActions(),
                      if (currentProposal.status == 'accepted')
                        _buildAcceptedActions(),
                      if (currentProposal.status == 'rejected')
                        _buildRejectedStatus(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (currentProposal.status) {
      case 'pending':
        statusColor = Colors.orange.shade600;
        statusText = 'En attente';
        statusIcon = Iconsax.clock;
        break;
      case 'accepted':
        statusColor = Colors.green.shade600;
        statusText = 'Acceptée';
        statusIcon = Iconsax.tick_circle;
        break;
      case 'rejected':
        statusColor = Colors.red.shade600;
        statusText = 'Rejetée';
        statusIcon = Iconsax.close_circle;
        break;
      default:
        statusColor = Colors.grey.shade600;
        statusText = 'Statut inconnu';
        statusIcon = Iconsax.info_circle;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statut de la proposition',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions sur cette proposition',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _updateProposalStatus('rejected'),
                  icon: const Icon(Iconsax.close_circle, size: 18),
                  label: const Text('Rejeter'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.red.shade300),
                    foregroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateProposalStatus('accepted'),
                  icon: const Icon(Iconsax.tick_circle, size: 18),
                  label: const Text('Accepter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Iconsax.tick_circle,
                  color: Colors.green.shade600,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Proposition acceptée',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cette proposition a été acceptée. Vous pouvez maintenant contacter le prestataire.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Iconsax.close_circle,
              color: Colors.red.shade600,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Proposition rejetée',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cette proposition a été rejetée.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderPendingActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.setting_2, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'Actions sur ma proposition',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Iconsax.clock,
                  color: Colors.orange.shade600,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Proposition en attente',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre proposition est en attente de réponse du client.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showCancelConfirmationDialog();
                  },
                  icon: const Icon(Iconsax.trash, size: 18),
                  label: const Text('Annuler'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.red.shade300),
                    foregroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Information',
                      'Fonctionnalité de modification à venir',
                      backgroundColor: Colors.blue.shade100,
                      colorText: Colors.black,
                    );
                  },
                  icon: const Icon(Iconsax.edit, size: 18),
                  label: const Text('Modifier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Annuler la proposition',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette proposition ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Non',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Fermer le dialog
              await _cancelProposal();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  // Supprimons les méthodes inutiles
  Future<void> _cancelProposal() async {
    try {
      await _proposalService.deleteProposal(currentProposal.id);
      
      Get.snackbar(
        'Succès',
        'Proposition annulée avec succès',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );

      // Retour à la page précédente
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'annulation : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  Future<void> _updateProposalStatus(String newStatus) async {
    try {
      if (newStatus == 'accepted') {
        await _proposalService.acceptProposal(currentProposal.id);
      } else if (newStatus == 'rejected') {
        await _proposalService.rejectProposal(currentProposal.id);
      }

      Get.snackbar(
        'Succès',
        'Proposition ${newStatus == 'accepted' ? 'acceptée' : 'rejetée'} avec succès',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );

      // Mettre à jour l'état local
      setState(() {
        currentProposal = ProposalModel(
          id: currentProposal.id,
          announcementId: currentProposal.announcementId,
          providerId: currentProposal.providerId,
          message: currentProposal.message,
          amount: currentProposal.amount,
          status: newStatus,
          createdAt: currentProposal.createdAt,
          provider: currentProposal.provider,
          announcement: currentProposal.announcement,
        );
      });
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la mise à jour : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }
}
