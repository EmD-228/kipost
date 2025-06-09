import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/controllers/work_controller.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/components/kipost_textfield.dart';
import 'package:kipost/models/proposal.dart';
import 'package:kipost/models/announcement.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                _buildProposalCard(),
                const SizedBox(height: 20),
                _buildAnnouncementCard(),
                const SizedBox(height: 20),
                _buildMessageCard(),
                const SizedBox(height: 20),
                if (currentProposal.status == 'en_attente' &&
                    _isCurrentUserReceiver)
                  _buildActionsButtons(),
                if (currentProposal.status == 'acceptée' &&
                    _isCurrentUserReceiver)
                  _buildScheduleCard(),
                if (currentProposal.status == 'planned' &&
                    _isCurrentUserReceiver)
                  _buildPlannedWorkCard(),
                // const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _updateProposalStatus('refusée');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),

            child: Text("Refuser"),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _updateProposalStatus('acceptée');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),

            child: Text("Accepter"),
          ),
        ),
      ],
    );
  }

  Widget _buildProposalCard() {
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
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  currentProposal.userEmail.isNotEmpty
                      ? currentProposal.userEmail.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentProposal.userEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Proposition • ${_formatDate(currentProposal.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(currentProposal.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard() {
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
              Icon(Iconsax.briefcase, color: Colors.deepPurple, size: 24),
              const SizedBox(width: 12),
              Text(
                'Annonce concernée',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingAnnouncement)
            const Center(child: CircularProgressIndicator())
          else if (_announcement != null) ...[
            Text(
              _announcement!.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _announcement!.category.icon,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _announcement!.category.name,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (_announcement!.price != null) ...[
                  Icon(Iconsax.money, size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${_announcement!.price} FCFA',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Iconsax.location, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _announcement!.location,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Annonce ID: ${currentProposal.announcementId}',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Impossible de charger les détails de l\'annonce',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
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
              Icon(Iconsax.message_text, color: Colors.deepPurple, size: 24),
              const SizedBox(width: 12),
              Text(
                'Message de proposition',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              currentProposal.message,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
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
              Icon(Iconsax.calendar, color: Colors.green.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'Planification du travail',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_showScheduleForm) ...[
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
                    'Proposition acceptée !',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Planifiez maintenant le travail avec le proposant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  KipostButton(
                    label: 'Planifier le travail',
                    onPressed: () {
                      setState(() {
                        _showScheduleForm = true;
                      });
                    },
                    icon: Iconsax.calendar_add,
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildScheduleForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de planification',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Date selection
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.calendar, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : 'Sélectionner une date',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _selectedDate != null
                                ? Colors.black
                                : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Icon(Iconsax.arrow_down_1, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Time selection
          GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.clock, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedTime != null
                          ? _formatTime(_selectedTime!)
                          : 'Sélectionner une heure',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _selectedTime != null
                                ? Colors.black
                                : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Icon(Iconsax.arrow_down_1, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Location
          KipostTextField(
            controller: _locationController,
            label: 'Lieu de rendez-vous',
            icon: Iconsax.location,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un lieu de rendez-vous';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Notes
          KipostTextField(
            controller: _notesController,
            label: 'Notes supplémentaires (optionnel)',
            icon: Iconsax.note,
            maxLines: 3,
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showScheduleForm = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KipostButton(
                  label: 'Planifier',
                  onPressed: _scheduleWork,
                  icon: Iconsax.calendar_tick,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'acceptée':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Acceptée';
        icon = Iconsax.tick_circle;
        break;
      case 'refusée':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'Refusée';
        icon = Iconsax.close_circle;
        break;
      case 'planned':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        label = 'Programmé';
        icon = Iconsax.close_circle;
        break;
      case 'en_attente':
      default:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = 'En attente';
        icon = Iconsax.clock;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

  String _formatDate(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
      await _workController
          .scheduleWork(
            proposalId: currentProposal.id,
            announcementId: currentProposal.announcementId,
            clientId: _announcement?.creatorId ?? 'unknown',
            providerId: currentProposal.userId,
            scheduledDate: _selectedDate!,
            scheduledTime: _selectedTime!.toString(),
            workLocation: _locationController.text.trim(),
            additionalNotes: _notesController.text.trim(),
          )
          .then((onValue) {
            _updateProposalStatus('planned');
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

  Future<void> _updateProposalStatus(String newStatus) async {
    try {
      await _proposalController.updateProposalStatus(
        currentProposal.id,
        newStatus,
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

  Widget _buildPlannedWorkCard() {
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.calendar_tick,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Travail planifié',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Détails de l\'intervention programmée',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PROGRAMMÉ',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Informations de planification
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                // Date
                _buildPlanningInfoRow(
                  icon: Iconsax.calendar,
                  color: Colors.blue.shade600,
                  label: 'Date',
                  value: 'À définir', // TODO: Récupérer la vraie date depuis WorkDetails
                ),
                const SizedBox(height: 16),
                
                // Heure
                _buildPlanningInfoRow(
                  icon: Iconsax.clock,
                  color: Colors.orange.shade600,
                  label: 'Heure',
                  value: 'À définir', // TODO: Récupérer la vraie heure depuis WorkDetails
                ),
                const SizedBox(height: 16),
                
                // Lieu
                _buildPlanningInfoRow(
                  icon: Iconsax.location,
                  color: Colors.green.shade600,
                  label: 'Lieu',
                  value: 'À définir', // TODO: Récupérer le vrai lieu depuis WorkDetails
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Naviguer vers les détails du travail ou permettre modification
                  },
                  icon: Icon(Iconsax.edit, size: 18, color: Colors.blue.shade600),
                  label: Text(
                    'Modifier',
                    style: TextStyle(color: Colors.blue.shade600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.blue.shade600),
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
                    // TODO: Naviguer vers le calendrier ou l'agenda
                  },
                  icon: const Icon(Iconsax.calendar_1, size: 18),
                  label: const Text('Mon agenda'),
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

  Widget _buildPlanningInfoRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
