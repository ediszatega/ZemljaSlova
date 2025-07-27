import 'package:flutter/material.dart';
import '../models/filter_field.dart';
import 'zs_button.dart';
import 'zs_dropdown.dart';

class FilterDialog extends StatefulWidget {
  final String title;
  final List<FilterField> fields;
  final Map<String, dynamic> initialValues;
  final Function(Map<String, dynamic>) onApplyFilters;
  final Function() onClearFilters;

  const FilterDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.initialValues,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late Map<String, dynamic> _values;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _values = Map.from(widget.initialValues);
    
    // Initialize controllers for text/number fields
    for (final field in widget.fields) {
      if (field.type == FilterFieldType.text || field.type == FilterFieldType.number) {
        _controllers[field.key] = TextEditingController(
          text: _values[field.key]?.toString() ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _applyFilters() {
    // Parse values from controllers
    for (final field in widget.fields) {
      if (field.type == FilterFieldType.text) {
        final text = _controllers[field.key]?.text ?? '';
        _values[field.key] = text.isNotEmpty ? text : null;
      } else if (field.type == FilterFieldType.number) {
        final text = _controllers[field.key]?.text ?? '';
        if (text.isNotEmpty) {
          // Try to parse as integer first, then as double
          final integer = int.tryParse(text);
          if (integer != null) {
            _values[field.key] = integer;
          } else {
            final number = double.tryParse(text);
            _values[field.key] = number;
          }
        } else {
          _values[field.key] = null;
        }
      }
    }

    widget.onApplyFilters(_values);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _values.clear();
      for (final controller in _controllers.values) {
        controller.clear();
      }
    });
    widget.onClearFilters();
  }

  Widget _buildField(FilterField field) {
    switch (field.type) {
      case FilterFieldType.text:
        return TextField(
          controller: _controllers[field.key],
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            suffixText: field.suffix,
            hintText: field.placeholder,
          ),
        );

      case FilterFieldType.number:
        return TextField(
          controller: _controllers[field.key],
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            suffixText: field.suffix,
            hintText: field.placeholder,
          ),
          keyboardType: TextInputType.number,
        );

      case FilterFieldType.date:
        return _buildDatePicker(field);

      case FilterFieldType.dropdown:
        return _buildDropdown(field);

      case FilterFieldType.checkbox:
        return _buildCheckbox(field);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDatePicker(FilterField field) {
    final selectedDate = _values[field.key] as DateTime?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: selectedDate != null 
                  ? '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}'
                  : '',
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _values[field.key] = null;
                        });
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setState(() {
                          _values[field.key] = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(FilterField field) {
    final options = field.dropdownOptions ?? [];
    final currentValue = _values[field.key];
    
    return ZSDropdown<String>(
      value: currentValue?.toString() ?? '',
      items: options.map((option) => DropdownMenuItem<String>(
        value: option.value,
        child: Text(option.label),
      )).toList(),
      onChanged: (value) {
        setState(() {
          if (value == null || value.isEmpty) {
            _values[field.key] = null;
          } else {
            final option = options.firstWhere((opt) => opt.value == value);
            _values[field.key] = option.data ?? value;
          }
        });
      },
      borderColor: Colors.grey.shade300,
    );
  }

  Widget _buildCheckbox(FilterField field) {
    final currentValue = _values[field.key] as bool? ?? false;
    
    return Row(
      children: [
        Checkbox(
          value: currentValue,
          onChanged: (value) {
            setState(() {
              _values[field.key] = value ?? false;
            });
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            field.label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 330,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Fields
            ...widget.fields.map((field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(field),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ZSButton(
                  onPressed: _clearFilters,
                  text: 'Očisti filtre',
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade700,
                  borderColor: Colors.grey.shade300,
                ),
                const SizedBox(width: 12),
                ZSButton(
                  onPressed: _applyFilters,
                  text: 'Primijeni filtre',
                  backgroundColor: const Color(0xFFE5FFEE),
                  foregroundColor: Colors.green,
                  borderColor: Colors.grey.shade300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 