import 'package:flutter/material.dart';

class ZSDatetimePicker extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime)? onDateTimeSelected;
  final String? Function(String?)? validator;

  const ZSDatetimePicker({
    super.key,
    required this.label,
    required this.controller,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateTimeSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 600,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            validator: validator,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate ?? DateTime.now(),
                    firstDate: firstDate ?? DateTime(1800),
                    lastDate: lastDate ?? DateTime.now().add(const Duration(days: 3650)), // Allow future dates
                  );
                  if (picked != null) {
                    // Show time picker after date is selected
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    
                    if (pickedTime != null) {
                      // Combine date and time
                      final DateTime dateTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      
                      // Format for display
                      controller.text = '${dateTime.day}.${dateTime.month}.${dateTime.year} ${pickedTime.hour}:${pickedTime.minute}';
                      
                      // Callback
                      if (onDateTimeSelected != null) {
                        onDateTimeSelected!(dateTime);
                      }
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
} 