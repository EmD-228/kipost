import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:kipost/services/proposal_service.dart';
import 'package:kipost/services/announcement_service.dart';
import 'package:kipost/services/auth_service.dart';
import 'package:kipost/components/proposal_detail/proposal_detail_widgets.dart';

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
                      // Message de candidature
                      ProposalMessageCard(proposal: currentProposal),
                      const SizedBox(height: 20),

                      // Informations du postulant
                      ProviderInfoCard(proposal: currentProposal),
                      const SizedBox(height: 20),

                      // Informations sur l'annonce
                      if (_announcement != null)
                        AnnouncementInfoCard(announcement: _announcement!),
                      if (_announcement != null)
                        const SizedBox(height: 20),

                      // Statut de la proposition
                      ProposalStatusCard(proposal: currentProposal),
                      const SizedBox(height: 20),

                      // Actions selon le statut
                      if (currentProposal.status == 'pending' && _isCurrentUserReceiver)
                        ReceiverActionsCard(
                          onAccept: () => _handleAcceptProposal(),
                          onReject: () => _handleRejectProposal(),
                        ),
                      if (currentProposal.status == 'pending' && _isCurrentUserSender)
                        SenderPendingActionsCard(
                          onCancel: () => _handleCancelProposal(),
                          onEdit: () => _handleEditProposal(),
                        ),
                      if (currentProposal.status == 'accepted')
                        const AcceptedActionsCard(),
                      if (currentProposal.status == 'rejected')
                        const RejectedStatusCard(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Méthodes de gestion des actions
  void _handleAcceptProposal() {
    ProposalDialogs.showAcceptConfirmationDialog(
      onConfirm: () => _updateProposalStatus('accepted'),
    );
  }

  void _handleRejectProposal() {
    ProposalDialogs.showRejectConfirmationDialog(
      onConfirm: () => _updateProposalStatus('rejected'),
    );
  }

  void _handleCancelProposal() {
    ProposalDialogs.showCancelConfirmationDialog(
      onConfirm: () => _cancelProposal(),
    );
  }

  void _handleEditProposal() {
    Get.snackbar(
      'Information',
      'Fonctionnalité de modification à venir',
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.black,
    );
  }

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
        
        // Recharger les données de l'annonce car elle a été mise à jour
        await _loadAnnouncementData();
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
