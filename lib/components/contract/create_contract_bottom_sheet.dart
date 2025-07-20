import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:kipost/services/contract_service.dart';
import 'package:kipost/components/kipost_textfield.dart';
import 'package:kipost/theme/app_colors.dart';
import 'package:kipost/components/text/app_text.dart';

class CreateContractBottomSheet extends StatefulWidget {
  final ProposalModel proposal;
  final AnnouncementModel announcement;

  const CreateContractBottomSheet({
    super.key,
    required this.proposal,
    required this.announcement,
  });

  @override
  State<CreateContractBottomSheet> createState() => _CreateContractBottomSheetState();
}

class _CreateContractBottomSheetState extends State<CreateContractBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final ContractService _contractService = ContractService();

  // Controllers
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();

  // Date et heure de début
  DateTime? _startDate;
  TimeOfDay? _startTime;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec les données de la proposition
    if (widget.proposal.amount != null) {
      _priceController.text = widget.proposal.amount!.toStringAsFixed(0);
    }
    // Pré-remplir avec les données de l'annonce
    if (widget.announcement.budget != null) {
      _priceController.text = widget.announcement.budget!.toStringAsFixed(0);
    }
    _locationController.text = widget.announcement.city ?? '';
  }

  @override
  void dispose() {
    _priceController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.heading2(
                        'Créer un contrat',
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      AppText.body(
                        'Définissez les détails du contrat avec ${widget.proposal.providerName}',
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Iconsax.close_square, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prix final
                    AppText.body(
                      'Prix final (CFA)',
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),
                    KipostTextField(
                      controller: _priceController,
                      label: 'Prix en CFA',
                      icon: Iconsax.money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un prix';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un montant valide';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Date et heure de début
                    AppText.body(
                      'Date et heure de début',
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Iconsax.calendar, color: Colors.grey),
                                  const SizedBox(width: 10),
                                  AppText.body(
                                    _startDate != null
                                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                        : 'Date',
                                    color: _startDate != null ? Colors.black87 : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectTime,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Iconsax.clock, color: Colors.grey),
                                  const SizedBox(width: 10),
                                  AppText.body(
                                    _startTime != null
                                        ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                                        : 'Heure',
                                    color: _startTime != null ? Colors.black87 : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Durée estimée
                    AppText.body(
                      'Durée estimée',
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),
                    KipostTextField(
                      controller: _durationController,
                      label: 'Ex: 2 heures, 1 jour, 1 semaine...',
                      icon: Iconsax.timer,
                    ),

                    const SizedBox(height: 20),

                    // Lieu de travail
                    AppText.body(
                      'Lieu de travail',
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),
                    KipostTextField(
                      controller: _locationController,
                      label: 'Adresse ou lieu de travail',
                      icon: Iconsax.location,
                    ),

                    const SizedBox(height: 20),

                    // Notes additionnelles
                    AppText.body(
                      'Notes additionnelles',
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),
                    KipostTextField(
                      controller: _notesController,
                      label: 'Instructions ou précisions supplémentaires...',
                      icon: Iconsax.note,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Bouton de création
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createContract,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : AppText.button('Créer le contrat'),
              ),
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
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
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _createContract() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final double finalPrice = double.parse(_priceController.text);
      
      DateTime? startDateTime;
      if (_startDate != null && _startTime != null) {
        startDateTime = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
          _startTime!.hour,
          _startTime!.minute,
        );
      }

      Map<String, dynamic>? finalLocation;
      if (_locationController.text.isNotEmpty) {
        finalLocation = {
          'address': _locationController.text,
          'city': widget.announcement.city,
          'country': widget.announcement.country,
        };
      }

      final contract = await _contractService.createContract(
        announcementId: widget.proposal.announcementId,
        proposalId: widget.proposal.id,
        clientId: widget.announcement.clientId,
        providerId: widget.proposal.providerId,
        finalPrice: finalPrice,
        startTime: startDateTime,
        estimatedDuration: _durationController.text.isNotEmpty ? _durationController.text : null,
        finalLocation: finalLocation,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      Get.back(result: contract);

      Get.snackbar(
        'Succès',
        'Contrat créé avec succès! En attente d\'approbation du prestataire.',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
        duration: const Duration(seconds: 4),
      );

    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la création du contrat : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Fonction helper pour afficher le bottom sheet
void showCreateContractBottomSheet({
  required ProposalModel proposal,
  required AnnouncementModel announcement,
}) {
  Get.bottomSheet(
    CreateContractBottomSheet(
      proposal: proposal,
      announcement: announcement,
    ),
    isScrollControlled: true,
    enableDrag: true,
    ignoreSafeArea: false,
  );
}
