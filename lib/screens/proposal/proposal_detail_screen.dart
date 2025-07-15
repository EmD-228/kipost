import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/proposal.dart';
import 'package:kipost/models/announcement.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/controllers/work_controller.dart';
import 'package:kipost/models/work_details.dart';
import 'package:kipost/utils/app_status.dart';
import 'package:kipost/utils/map_utils.dart';
import 'package:kipost/components/proposal/proposal_card.dart';
import 'package:kipost/components/proposal/announcement_card.dart';
import 'package:kipost/components/proposal/message_card.dart';
import 'package:kipost/components/proposal/schedule_card.dart';
import 'package:kipost/components/proposal/planned_work_card.dart';
import 'package:kipost/components/proposal/action_buttons_section.dart';
import 'package:kipost/components/proposal/sender_actions_card.dart';

class ProposalDetailScreen extends StatefulWidget {
  final Proposal proposal;
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
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final WorkController _workController = Get.put(WorkController());
  final ProposalController _proposalController = Get.put(ProposalController());

  late Proposal currentProposal;
  late WorkDetails currentWorkDetails;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _showScheduleForm = false;
  Announcement? _announcement;
  bool _loadingAnnouncement = true;

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
      final announcement = await _proposalController.getAnnouncementForProposal(
        currentProposal.announcementId,
      );
      await _workController.getWorkDetailsByProposal(currentProposal.id).then((
        workDetails,
      ) {
        if (workDetails != null) {
          currentWorkDetails = workDetails;
        }
      });
      setState(() {
        _announcement = announcement;
        _loadingAnnouncement = false;
      });
    } catch (e) {
      print('Error loading announcement: $e');
      setState(() {
        _loadingAnnouncement = false;
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
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid == currentProposal.userId;
  }

  bool get _isCurrentUserReceiver {
    final currentUser = FirebaseAuth.instance.currentUser;
    return _announcement?.creatorId == currentUser?.uid;
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProposalCard(
                  proposal: currentProposal,
                  announcementCreatorEmail: _announcement?.creatorEmail,
                  isCurrentUserSender: _isCurrentUserSender,
                ),
                const SizedBox(height: 20),
                AnnouncementCard(
                  announcement: _announcement,
                  isLoading: _loadingAnnouncement,
                  announcementId: currentProposal.announcementId,
                ),
                const SizedBox(height: 20),
                MessageCard(message: currentProposal.message),
                const SizedBox(height: 20),
                if (currentProposal.status == 'pending' &&
                    _isCurrentUserReceiver)
                  ActionButtonsSection(
                    proposal: currentProposal,
                    onAccept: () => _updateProposalStatus(ProposalStatus.accepted),
                    onReject: () => _updateProposalStatus(ProposalStatus.rejected),
                    onContact: () {
                      // TODO: Implement contact functionality
                    },
                  ),
                if (currentProposal.status == 'pending' &&
                    _isCurrentUserSender)
                  _buildSenderPendingActions(),
                if (currentProposal.status == 'accepted' &&
                    currentProposal.workDetailId.isEmpty &&
                    _isCurrentUserReceiver)
                  ScheduleCard(
                    showScheduleForm: _showScheduleForm,
                    onPlanifyPressed: () {
                      setState(() {
                        _showScheduleForm = true;
                      });
                    },
                    onScheduleWork: _scheduleWork,
                    onCancel: () {
                      setState(() {
                        _showScheduleForm = false;
                      });
                    },
                    formKey: _formKey,
                    locationController: _locationController,
                    notesController: _notesController,
                    selectedDate: _selectedDate,
                    selectedTime: _selectedTime,
                    onSelectDate: _selectDate,
                    onSelectTime: _selectTime,
                  ),
                if (currentProposal.status == 'accepted' &&
                    currentProposal.workDetailId.isNotEmpty &&
                    _isCurrentUserReceiver)
                  PlannedWorkCard(proposal: currentProposal),
                if (currentProposal.status == 'accepted' &&
                    currentProposal.workDetailId.isNotEmpty &&
                    _isCurrentUserSender)
                  SenderActionsCard(
                    onCalendarPressed: () {
                      // TODO: Navigate to calendar
                    },
                    onChatPressed: () {
                      // TODO: Navigate to chat
                    },
                    onLocationPressed: () async {
                      try {
                        if (currentWorkDetails.workLocation != null && 
                            currentWorkDetails.workLocation!.isNotEmpty) {
                          // Si on a une adresse textuelle, on l'utilise
                          await MapUtils.openGoogleMapsWithAddress(currentWorkDetails.workLocation!);
                        } else {
                          Get.snackbar(
                            'Information',
                            'Aucune localisation disponible',
                            backgroundColor: Colors.orange.shade100,
                            colorText: Colors.black,
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'Erreur',
                          'Impossible d\'ouvrir la carte : $e',
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.black,
                        );
                      }
                    },
                  ),
                // const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleWork() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      Get.snackbar(
        'Information',
        'Veuillez sélectionner une date et une heure',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black,
      );
      return;
    }

    try {
      // _updateProposalStatus('planned');

      await _workController
          .scheduleWork(
            announcementId: currentProposal.announcementId,
            proposalId: currentProposal.id,
            clientId: _announcement?.creatorId ?? 'unknown',
            providerId: currentProposal.userId,
            scheduledDate: _selectedDate!,
            scheduledTime: _selectedTime!.toString(),
            workLocation: _locationController.text.trim(),
            additionalNotes: _notesController.text.trim(),
          )
          .then((workDetailId) async {
            // Update the proposal status to 'planned'
            await _updateProposalStatus(
              currentProposal.status,
              workDetailId: workDetailId,
            );
          });

      Get.snackbar(
        'Succès',
        'Travail planifié avec succès !',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );

      // Retour à la page précédente
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la planification : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
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
                  icon: Icon(Iconsax.trash, size: 18),
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
                    // TODO: Navigate to edit proposal screen
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

  Future<void> _cancelProposal() async {
    try {
      await _proposalController.deleteProposal(currentProposal.id);
      
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

  Future<void> _updateProposalStatus(
    String newStatus, {
    String? workDetailId,
  }) async {
    try {
      await _proposalController.updateProposalStatus(
        currentProposal.id,
        newStatus,
        workDetailId: workDetailId,
      );

      Get.snackbar(
        'Succès',
        'Proposition ${newStatus} avec succès',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );

      // Mettre à jour l'état local
      setState(() {
        // Update currentProposal status
        currentProposal = Proposal(
          id: currentProposal.id,
          announcementId: currentProposal.announcementId,
          userId: currentProposal.userId,
          userEmail: currentProposal.userEmail,
          message: currentProposal.message,
          createdAt: currentProposal.createdAt,
          status: newStatus,
          workDetailId: workDetailId ?? "",
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
