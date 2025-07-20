import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../models/member.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_date_picker.dart';
import '../widgets/zs_dropdown.dart';

class MemberEditScreen extends StatefulWidget {
  final int memberId;
  
  const MemberEditScreen({
    super.key,
    required this.memberId,
  });

  @override
  State<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  
  String? _selectedGender;
  final List<String> _genderOptions = ['Muški', 'Ženski'];
  
  bool _isLoading = true;
  DateTime? _dateOfBirth;
  Member? _member;

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }
  
  Future<void> _loadMemberData() async {
    setState(() {
      _isLoading = true;
    });
    
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    
    try {
      final member = await memberProvider.getMemberById(widget.memberId);
      
      if (member != null) {
        setState(() {
          _member = member;
          
          _firstNameController.text = member.firstName;
          _lastNameController.text = member.lastName;
          _emailController.text = member.email;
          _dateOfBirth = member.dateOfBirth;
          _dateOfBirthController.text = '${member.dateOfBirth.day}.${member.dateOfBirth.month}.${member.dateOfBirth.year}';
          
          switch (member.gender?.toLowerCase()) {
            case 'male':
              _selectedGender = 'Muški';
              break;
            case 'female':
              _selectedGender = 'Ženski';
              break;
            default:
              _selectedGender = member.gender;
          }
          
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Korisnik nije pronađen'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška prilikom učitavanja korisnika: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
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
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Nazad na pregled korisnika'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Uređivanje korisnika',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Form
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // First name field
                                  ZSInput(
                                    label: 'Ime*',
                                    controller: _firstNameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Unesite ime korisnika';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Last name field
                                  ZSInput(
                                    label: 'Prezime*',
                                    controller: _lastNameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Unesite prezime korisnika';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Email field
                                  ZSInput(
                                    label: 'Email*',
                                    controller: _emailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Unesite email korisnika';
                                      }
                                      
                                      // Simple email validation
                                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Unesite validan email';
                                      }
                                      
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Gender dropdown
                                  ZSDropdown<String?>(
                                    label: 'Spol',
                                    value: _selectedGender,
                                    items: _genderOptions.map((gender) => 
                                      DropdownMenuItem<String?>(
                                        value: gender,
                                        child: Text(gender),
                                      )
                                    ).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Date of birth field with datepicker
                                  ZSDatePicker(
                                    label: 'Datum rođenja*',
                                    controller: _dateOfBirthController,
                                    initialDate: _dateOfBirth,
                                    onDateSelected: (date) {
                                      setState(() {
                                        _dateOfBirth = date;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Odaberite datum rođenja';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Submit buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ZSButton(
                                        text: 'Spremi promjene',
                                        backgroundColor: Colors.green.shade50,
                                        foregroundColor: Colors.green,
                                        borderColor: Colors.grey.shade300,
                                        width: 250,
                                        onPressed: _submitMemberUpdate,
                                      ),
                                      
                                      const SizedBox(width: 20),
                                      
                                      ZSButton(
                                        text: 'Odustani',
                                        backgroundColor: Colors.grey.shade100,
                                        foregroundColor: Colors.grey.shade700,
                                        borderColor: Colors.grey.shade300,
                                        width: 250,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 40),
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
  
  void _submitMemberUpdate() {
    if (_formKey.currentState!.validate()) {
      // Validate fields
      if (_dateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Odaberite datum rođenja'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      
      setState(() {
        _isLoading = true;
      });
      
      String? backendGender;
      switch (_selectedGender) {
        case 'Muški':
          backendGender = 'male';
          break;
        case 'Ženski':
          backendGender = 'female';
          break;
        default:
          backendGender = _selectedGender;
      
      memberProvider.updateMember(
        widget.memberId,
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _dateOfBirth!,
        backendGender,
      ).then((member) {
        setState(() {
          _isLoading = false;
        });
        
        if (member != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(memberProvider.error != null 
                ? 'Korisnik je ažuriran, ali: ${memberProvider.error}'
                : 'Korisnik je uspješno ažuriran!'),
              backgroundColor: memberProvider.error != null ? Colors.orange : Colors.green,
            ),
          );
          
          Navigator.pop(context, member);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška prilikom ažuriranja korisnika: ${memberProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
} 