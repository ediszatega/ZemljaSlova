import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';
import '../widgets/zs_button.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/image_display_widget.dart';

class ProfileEditScreen extends StatefulWidget {
  final Member member;
  
  const ProfileEditScreen({
    super.key,
    required this.member,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  
  String? _selectedGender;
  Uint8List? _selectedImage;
  Uint8List? _initialImage;
  bool _isLoading = false;
  DateTime? _selectedDate;

  final List<String> _genderOptions = ['Muški', 'Ženski'];

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  void _loadMemberData() {
    _firstNameController.text = widget.member.firstName;
    _lastNameController.text = widget.member.lastName;
    _emailController.text = widget.member.email;
    _selectedDate = widget.member.dateOfBirth;
    _dateOfBirthController.text = _formatDate(widget.member.dateOfBirth);
    
    // Set gender
    if (widget.member.gender != null) {
      switch (widget.member.gender!.toLowerCase()) {
        case 'male':
          _selectedGender = 'Muški';
          break;
        case 'female':
          _selectedGender = 'Ženski';
          break;
        default:
          _selectedGender = widget.member.gender;
      }
    }

    _initialImage = null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String? _mapGenderToBackend(String? gender) {
    if (gender == null) return null;
    
    switch (gender) {
      case 'Muški':
        return 'male';
      case 'Ženski':
        return 'female';
      default:
        return gender;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Molimo odaberite datum rođenja'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      
      final success = await memberProvider.updateMember(
        id: widget.member.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        dateOfBirth: _selectedDate!,
        gender: _mapGenderToBackend(_selectedGender),
        imageBytes: _selectedImage,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil je uspješno ažuriran'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(memberProvider.error ?? 'Greška prilikom ažuriranja profila'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Uredi profil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Column(
                  children: [
                    // Current Image Display
                    if (widget.member.profileImageUrl != null && widget.member.profileImageUrl!.isNotEmpty)
                      Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: ClipOval(
                          child: ImageDisplayWidget.profile(
                            imageUrl: widget.member.profileImageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                      ),
                    
                    // Image Picker
                    ImagePickerWidget(
                      label: 'Profilna slika',
                      initialImage: _initialImage,
                      onImageSelected: (imageBytes) {
                        setState(() {
                          _selectedImage = imageBytes;
                        });
                      },
                      width: 200,
                      height: 200,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Personal Information Section
              const Text(
                'Lični podaci',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Ime *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Unesite ime';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Prezime *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Unesite prezime';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Unesite email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Unesite validan email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Date of Birth
              TextFormField(
                controller: _dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: 'Datum rođenja *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Odaberite datum rođenja';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Spol',
                  border: OutlineInputBorder(),
                ),
                items: _genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ZSButton(
                  text: 'Spremi promjene',
                  onPressed: _isLoading ? null : _saveProfile,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  borderColor: Colors.blue,
                  borderRadius: 8,
                  paddingVertical: 16,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  topPadding: 0,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: ZSButton(
                  text: 'Otkaži',
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade700,
                  borderColor: Colors.grey.shade300,
                  borderRadius: 8,
                  paddingVertical: 16,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  topPadding: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
