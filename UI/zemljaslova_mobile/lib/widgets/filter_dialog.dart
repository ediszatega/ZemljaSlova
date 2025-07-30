import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/filter_field.dart';
import '../models/author.dart';
import '../providers/author_provider.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/zs_input.dart';

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
    
    // Load authors if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAuthorsIfNeeded();
    });
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

  void _loadAuthorsIfNeeded() async {
    // Check if any field needs authors
    final needsAuthors = widget.fields.any((field) => 
      field.type == FilterFieldType.dropdown && 
      field.key == 'authorId'
    );
    
    if (needsAuthors) {
      final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
      await authorProvider.fetchAuthors();
    }
  }

  Widget _buildField(FilterField field) {
    switch (field.type) {
      case FilterFieldType.text:
        return ZSInput(
          controller: _controllers[field.key]!,
          label: field.label,
          hintText: field.placeholder ?? '',
        );
        
      case FilterFieldType.number:
        return ZSInput(
          controller: _controllers[field.key]!,
          label: field.label,
          hintText: field.placeholder ?? '',
          keyboardType: TextInputType.number,
        );
        
      case FilterFieldType.date:
        return _buildDateField(field);
        
      case FilterFieldType.dropdown:
        return _buildDropdownField(field);
        
      case FilterFieldType.checkbox:
        return _buildCheckboxField(field);
    }
  }

  Widget _buildDateField(FilterField field) {
    final currentValue = _values[field.key];
    DateTime? selectedDate;
    if (currentValue != null) {
      if (currentValue is int) {
        selectedDate = DateTime.fromMillisecondsSinceEpoch(currentValue);
      } else if (currentValue is DateTime) {
        selectedDate = currentValue;
      }
    }

    return GestureDetector(
      onTap: () => _selectDate(field.key),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              selectedDate != null 
                  ? _formatDate(selectedDate)
                  : field.placeholder ?? 'Odaberi datum',
              style: TextStyle(
                color: selectedDate != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(FilterField field) {
    final currentValue = _values[field.key];
    
    // Handle author dropdown specifically
    if (field.key == 'authorId') {
      return Consumer<AuthorProvider>(
        builder: (context, authorProvider, child) {
          final authors = authorProvider.authors;
          final options = [
            const FilterDropdownOption(value: '', label: 'Svi autori', data: null),
            ...authors.map((author) => FilterDropdownOption(
              value: author.id.toString(),
              label: '${author.firstName} ${author.lastName}',
              data: author,
            )),
          ];
          
          // Get the current author ID as string
          String currentAuthorId = '';
          if (currentValue != null) {
            if (currentValue is int) {
              currentAuthorId = currentValue.toString();
            } else if (currentValue is String) {
              currentAuthorId = currentValue;
            } else if (currentValue is Author) {
              currentAuthorId = currentValue.id.toString();
            }
          }
          
          return ZSDropdown<String>(
            label: field.label,
            value: currentAuthorId,
            items: options.map((option) => DropdownMenuItem<String>(
              value: option.value,
              child: Text(option.label),
            )).toList(),
            onChanged: (String? value) {
              setState(() {
                if (value != null && value.isNotEmpty) {
                  final option = options.firstWhere((opt) => opt.value == value);
                  // Store the author ID (int) instead of the Author object
                  if (option.data is Author) {
                    _values[field.key] = (option.data as Author).id;
                  } else {
                    _values[field.key] = option.data;
                  }
                } else {
                  _values[field.key] = null;
                }
              });
            },
          );
        },
      );
    }
    
    // Handle other dropdowns
    final options = field.dropdownOptions ?? [];
    return ZSDropdown<String>(
      label: field.label,
      value: currentValue?.toString() ?? '',
      items: options.map((option) => DropdownMenuItem<String>(
        value: option.value,
        child: Text(option.label),
      )).toList(),
      onChanged: (String? value) {
        setState(() {
          if (value != null && value.isNotEmpty) {
            final option = options.firstWhere((opt) => opt.value == value);
            _values[field.key] = option.data;
          } else {
            _values[field.key] = null;
          }
        });
      },
    );
  }

  Widget _buildCheckboxField(FilterField field) {
    final currentValue = _values[field.key] ?? false;
    
    return Row(
      children: [
        Checkbox(
          value: currentValue,
          onChanged: (bool? value) {
            setState(() {
              _values[field.key] = value ?? false;
            });
          },
        ),
        Expanded(
          child: Text(field.label),
        ),
      ],
    );
  }

  Future<void> _selectDate(String fieldKey) async {
    final currentValue = _values[fieldKey];
    DateTime? initialDate;
    if (currentValue != null) {
      if (currentValue is int) {
        initialDate = DateTime.fromMillisecondsSinceEpoch(currentValue);
      } else if (currentValue is DateTime) {
        initialDate = currentValue;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _values[fieldKey] = picked.millisecondsSinceEpoch;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < widget.fields.length; i++) ...[
                      if (i > 0) const SizedBox(height: 20),
                      _buildField(widget.fields[i]),
                    ],
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ZSButton(
                      onPressed: _clearFilters,
                      text: 'Očisti',
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ZSButton(
                      onPressed: _applyFilters,
                      text: 'Primijeni',
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 