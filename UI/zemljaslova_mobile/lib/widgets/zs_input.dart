import 'package:flutter/material.dart';

class ZSInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;
  final String? suffixText;

  const ZSInput({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.obscureText = false,
    this.hintText,
    this.suffixText,
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
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            maxLines: obscureText ? 1 : maxLines,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              hintText: hintText,
              suffixText: suffixText,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
              suffixStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 