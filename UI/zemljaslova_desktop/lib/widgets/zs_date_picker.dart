import 'package:flutter/material.dart';

class ZSDatePicker extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime)? onDateSelected;
  final String? Function(String?)? validator;

  const ZSDatePicker({
    super.key,
    required this.label,
    required this.controller,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
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
                    firstDate: firstDate ?? DateTime(1900),
                    lastDate: lastDate ?? DateTime.now(),
                  );
                  
                  if (picked != null) {
                    // Format date for display day.month.year
                    final day = picked.day.toString().padLeft(2, '0');
                    final month = picked.month.toString().padLeft(2, '0');
                    final year = picked.year.toString();
                    
                    controller.text = '$day.$month.$year';
                    
                    if (onDateSelected != null) {
                      // Create a DateTime at noon to avoid timezone issues
                      final date = DateTime(picked.year, picked.month, picked.day, 12, 0, 0);
                      onDateSelected!(date);
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