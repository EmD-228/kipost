import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/components/kipost_textfield.dart';

class ScheduleCard extends StatefulWidget {
  final bool showScheduleForm;
  final VoidCallback onPlanifyPressed;
  final VoidCallback onScheduleWork;
  final VoidCallback onCancel;
  final GlobalKey<FormState> formKey;
  final TextEditingController locationController;
  final TextEditingController notesController;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  const ScheduleCard({
    super.key,
    required this.showScheduleForm,
    required this.onPlanifyPressed,
    required this.onScheduleWork,
    required this.onCancel,
    required this.formKey,
    required this.locationController,
    required this.notesController,
    this.selectedDate,
    this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.grey.shade200),
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
                  fontSize: 16,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!widget.showScheduleForm) ...[
            _buildSuccessView(),
          ] else ...[
            _buildScheduleForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Container(
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
            onPressed: widget.onPlanifyPressed,
            icon: Iconsax.calendar_add,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleForm() {
    return Form(
      key: widget.formKey,
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
            onTap: widget.onSelectDate,
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
                      widget.selectedDate != null
                          ? _formatDate(widget.selectedDate!)
                          : 'Sélectionner une date',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.selectedDate != null
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
            onTap: widget.onSelectTime,
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
                      widget.selectedTime != null
                          ? _formatTime(widget.selectedTime!)
                          : 'Sélectionner une heure',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.selectedTime != null
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
            controller: widget.locationController,
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
            controller: widget.notesController,
            label: 'Notes supplémentaires (optionnel)',
            icon: Iconsax.note,
            maxLines: 3,
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
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
                  onPressed: widget.onScheduleWork,
                  icon: Iconsax.calendar_tick,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
}
