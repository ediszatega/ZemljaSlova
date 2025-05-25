import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voucher_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_date_picker.dart';

class VoucherAddScreen extends StatefulWidget {
  const VoucherAddScreen({super.key});

  @override
  State<VoucherAddScreen> createState() => _VoucherAddScreenState();
}

class _VoucherAddScreenState extends State<VoucherAddScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  
  bool _isLoading = false;
  DateTime? _selectedExpirationDate;

  @override
  void dispose() {
    _valueController.dispose();
    _codeController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          const SidebarWidget(),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 44, left: 80.0, right: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Nazad na pregled vaučera'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Dodavanje novog vaučera',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Value field
                            ZSInput(
                              label: 'Vrijednost (KM)',
                              controller: _valueController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Molimo unesite vrijednost';
                                }
                                final doubleValue = double.tryParse(value);
                                if (doubleValue == null || doubleValue <= 0) {
                                  return 'Molimo unesite validnu vrijednost';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Custom code field (optional)
                            ZSInput(
                              label: 'Kod vaučera (opcionalno)',
                              controller: _codeController,
                              validator: (value) {
                                if (value != null && value.isNotEmpty && value.length < 4) {
                                  return 'Kod mora imati najmanje 4 karaktera';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Expiration date
                            ZSDatePicker(
                              label: 'Datum isteka',
                              controller: _expirationDateController,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years in the future
                              onDateSelected: (date) {
                                setState(() {
                                  _selectedExpirationDate = date;
                                });
                              },
                              validator: (value) {
                                if (_selectedExpirationDate == null) {
                                  return 'Molimo odaberite datum isteka';
                                }
                                if (_selectedExpirationDate!.isBefore(DateTime.now())) {
                                  return 'Datum isteka mora biti u budućnosti';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Submit buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ZSButton(
                                  text: 'Spremi',
                                  backgroundColor: Colors.green.shade50,
                                  foregroundColor: Colors.green,
                                  borderColor: Colors.grey.shade300,
                                  width: 250,
                                  onPressed: _submitForm,
                                ),
                                
                                const SizedBox(width: 20),
                                
                                ZSButton(
                                  text: 'Odustani',
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.grey.shade700,
                                  borderColor: Colors.grey.shade300,
                                  width: 250,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final value = double.parse(_valueController.text);
    final voucherProvider = Provider.of<VoucherProvider>(context, listen: false);

    bool success = false;

    if (_selectedExpirationDate != null) {
      success = await voucherProvider.createAdminVoucher(
        value: value,
        expirationDate: _selectedExpirationDate!,
        code: _codeController.text.isNotEmpty ? _codeController.text : null,
      );
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vaučer je uspješno kreiran'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška: ${voucherProvider.error ?? "Nepoznata greška"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 