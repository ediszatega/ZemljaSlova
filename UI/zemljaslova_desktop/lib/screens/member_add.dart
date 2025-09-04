import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../utils/password_validator.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_date_picker.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/image_picker_widget.dart';

class MemberAddScreen extends StatefulWidget {
  const MemberAddScreen({super.key});

  @override
  State<MemberAddScreen> createState() => _MemberAddScreenState();
}

class _MemberAddScreenState extends State<MemberAddScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  
  String? _selectedGender;
  final List<String> _genderOptions = ['Muški', 'Ženski'];
  Uint8List? _selectedImage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/members',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Nazad na pregled korisnika'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Dodavanje novog korisnika',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Form
                  Expanded(
                    child: Form(
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
                            
                            // Password field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lozinka*',
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
                                    controller: _passwordController,
                                    obscureText: true,
                                    validator: (value) {
                                      return PasswordValidator.validatePassword(value ?? '');
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Image picker
                            ImagePickerWidget(
                              label: 'Profilna slika',
                              onImageSelected: (imageBytes) {
                                setState(() {
                                  _selectedImage = imageBytes;
                                });
                              },
                              width: 150,
                              height: 150,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Odaberite datum rođenja';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Submit button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ZSButton(
                                  text: 'Spremi',
                                  backgroundColor: Colors.green.shade50,
                                  foregroundColor: Colors.green,
                                  borderColor: Colors.grey.shade300,
                                  width: 250,
                                  onPressed: _saveMember,
                                ),
                                
                                const SizedBox(width: 20),
                                
                                ZSButton(
                                  text: 'Odustani',
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.grey.shade700,
                                  borderColor: Colors.grey.shade300,
                                  width: 250,
                                  onPressed: () {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/members',
                                      (route) => false,
                                    );
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
  
  void _saveMember() {
    if (_formKey.currentState!.validate()) {
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      
      DateTime dateOfBirth = DateTime.now();
      if (_dateOfBirthController.text.isNotEmpty) {
        try {
          final parts = _dateOfBirthController.text.split('.');
          if (parts.length == 3) {
            dateOfBirth = DateTime(
              int.parse(parts[2]),  
              int.parse(parts[1]),  
              int.parse(parts[0]),  
              12, 0, 0,             
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Neispravan format datuma rođenja'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
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
      }
      
      memberProvider.addMember(
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _passwordController.text,
        dateOfBirth,
        backendGender,
        imageBytes: _selectedImage,
      ).then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Korisnik uspješno dodan!'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/members',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška prilikom dodavanja korisnika: ${memberProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
} 