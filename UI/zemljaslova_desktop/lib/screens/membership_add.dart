import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/membership_provider.dart';
import '../providers/member_provider.dart';
import '../models/member.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_date_picker.dart';

class MembershipAddScreen extends StatefulWidget {
  const MembershipAddScreen({super.key});

  @override
  State<MembershipAddScreen> createState() => _MembershipAddScreenState();
}

class _MembershipAddScreenState extends State<MembershipAddScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  Member? _selectedMember;

  @override
  void initState() {
    super.initState();
    // Fetch members when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
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
                    label: const Text('Nazad na pregled članarina'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Dodavanje nove članarine',
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
                            // Member selection dropdown
                            Consumer<MemberProvider>(
                              builder: (context, memberProvider, child) {
                                if (memberProvider.isLoading) {
                                  return const CircularProgressIndicator();
                                }

                                final members = memberProvider.members;
                                final memberOptions = members.map((member) => 
                                    DropdownMenuItem(
                                      value: member,
                                      child: Text('${member.firstName} ${member.lastName}'),
                                    )
                                ).toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Odaberite člana',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<Member>(
                                      value: _selectedMember,
                                      items: memberOptions,
                                      onChanged: (member) {
                                        setState(() {
                                          _selectedMember = member;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Molimo odaberite člana';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      hint: const Text('Odaberite člana...'),
                                    ),
                                  ],
                                );
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Start date
                            ZSDatePicker(
                              label: 'Datum početka',
                              controller: _startDateController,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              onDateSelected: (date) {
                                setState(() {
                                  _selectedStartDate = date;
                                  // Auto-set end date to 30 days after start date
                                  if (date != null) {
                                    _selectedEndDate = date.add(const Duration(days: 30));
                                    _endDateController.text = _formatDate(_selectedEndDate!);
                                  }
                                });
                              },
                              validator: (value) {
                                if (_selectedStartDate == null) {
                                  return 'Molimo odaberite datum početka';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // End date
                            ZSDatePicker(
                              label: 'Datum kraja',
                              controller: _endDateController,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
                              onDateSelected: (date) {
                                setState(() {
                                  _selectedEndDate = date;
                                });
                              },
                              validator: (value) {
                                if (_selectedEndDate == null) {
                                  return 'Molimo odaberite datum kraja';
                                }
                                if (_selectedStartDate != null && _selectedEndDate!.isBefore(_selectedStartDate!)) {
                                  return 'Datum kraja mora biti nakon datuma početka';
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

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final membershipProvider = Provider.of<MembershipProvider>(context, listen: false);

    bool success = false;

    if (_selectedMember != null && _selectedStartDate != null && _selectedEndDate != null) {
      success = await membershipProvider.createMembershipByAdmin(
        memberId: _selectedMember!.id,
        startDate: _selectedStartDate!,
        endDate: _selectedEndDate!,
      );
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Članarina je uspješno kreirana'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška: ${membershipProvider.error ?? "Nepoznata greška"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 