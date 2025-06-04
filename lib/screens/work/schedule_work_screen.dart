import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/controllers/work_controller.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/components/kipost_textfield.dart';

class ScheduleWorkScreen extends StatefulWidget {
  final String proposalId;
  final String announcementId;
  final String providerId;
  final String clientId;
  final String announcementTitle;
  final String providerName;

  const ScheduleWorkScreen({
    super.key,
    required this.proposalId,
    required this.announcementId,
    required this.providerId,
    required this.clientId,
    required this.announcementTitle,
    required this.providerName,
  });

  @override
  State<ScheduleWorkScreen> createState() => _ScheduleWorkScreenState();
}

class _ScheduleWorkScreenState extends State<ScheduleWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final WorkController _workController = Get.put(WorkController());

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
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

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
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

    await _workController.scheduleWork(
      proposalId: widget.proposalId,
      announcementId: widget.announcementId,
      clientId: widget.clientId,
      providerId: widget.providerId,
      scheduledDate: _selectedDate!,
      scheduledTime: _formatTime(_selectedTime!),
      workLocation: _locationController.text.trim(),
      additionalNotes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Iconsax.arrow_left,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Planifier le travail',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations sur le travail
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Iconsax.briefcase,
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
                                'Détails du travail',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Planifiez votre intervention',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Annonce : ${widget.announcementTitle}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Prestataire : ${widget.providerName}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sélection de la date
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.calendar,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    _selectedDate != null 
                        ? _formatDate(_selectedDate!) 
                        : 'Sélectionner une date',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _selectedDate != null 
                          ? Colors.grey.shade800 
                          : Colors.grey.shade500,
                    ),
                  ),
                  subtitle: Text(
                    'Date de l\'intervention',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Icon(
                    Iconsax.arrow_right_3,
                    color: Colors.grey.shade400,
                  ),
                  onTap: _selectDate,
                ),
              ),

              const SizedBox(height: 16),

              // Sélection de l'heure
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.clock,
                      color: Colors.orange.shade600,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    _selectedTime != null 
                        ? _formatTime(_selectedTime!) 
                        : 'Sélectionner une heure',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _selectedTime != null 
                          ? Colors.grey.shade800 
                          : Colors.grey.shade500,
                    ),
                  ),
                  subtitle: Text(
                    'Heure de l\'intervention',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Icon(
                    Iconsax.arrow_right_3,
                    color: Colors.grey.shade400,
                  ),
                  onTap: _selectTime,
                ),
              ),

              const SizedBox(height: 24),

              // Localisation
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: KipostTextField(
                  controller: _locationController,
                  label: 'Lieu de l\'intervention',
                  icon: Iconsax.location,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez préciser le lieu';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Notes supplémentaires
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: KipostTextField(
                  controller: _notesController,
                  label: 'Notes supplémentaires (optionnel)',
                  icon: Iconsax.note,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                ),
              ),

              const SizedBox(height: 32),

              // Bouton de planification
              Obx(() => KipostButton(
                label: _workController.loading.value 
                    ? 'Planification...' 
                    : 'Planifier le travail',
                icon: Iconsax.calendar_add,
                onPressed: _workController.loading.value ? null : _scheduleWork,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
