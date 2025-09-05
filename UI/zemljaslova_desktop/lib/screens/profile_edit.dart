import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/image_picker_widget.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  String? _selectedGender;
  final List<String> _genderOptions = ['Muški', 'Ženski'];
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  Uint8List? _selectedImage;
  Uint8List? _initialImage;
  Map<String, dynamic>? _currentUserProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }
  
  Future<void> _loadUserProfileData() async {
    setState(() {
      _isLoading = true;
    });
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      await userProvider.loadCurrentUserProfile();
      final currentUser = userProvider.currentUserProfile;
      
      if (currentUser != null) {
        setState(() {
          _currentUserProfile = currentUser;
          _firstNameController.text = currentUser['firstName'] ?? '';
          _lastNameController.text = currentUser['lastName'] ?? '';
          _emailController.text = currentUser['email'] ?? '';
          
          // Map gender from backend to UI
          String? backendGender = currentUser['gender'];
          if (backendGender != null && backendGender != 'Nije navedeno') {
            switch (backendGender.toLowerCase()) {
              case 'male':
                _selectedGender = 'Muški';
                break;
              case 'female':
                _selectedGender = 'Ženski';
                break;
              default:
                _selectedGender = backendGender;
            }
          }
          
          // Load existing image if available
          String? profileImageUrl = currentUser['profileImageUrl'];
          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            _loadProfileImage(profileImageUrl);
          }
          
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška prilikom učitavanja profila'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška prilikom učitavanja profila: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _loadProfileImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          _initialImage = response.bodyBytes;
        });
      } else {
        setState(() {
          _initialImage = null;
        });
      }
    } catch (e) {
      // Silently fail - user can still select a new image
      setState(() {
        _initialImage = null;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
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
                    label: const Text('Nazad na pregled profila'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Uređivanje profila',
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
                                        return 'Unesite ime';
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
                                        return 'Unesite prezime';
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
                                        return 'Unesite email';
                                      }
                                      
                                      // Email validation
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
                                  
                                  // Profile image picker
                                  ImagePickerWidget(
                                    label: 'Profilna slika',
                                    initialImage: _initialImage,
                                    onImageSelected: (imageBytes) {
                                      setState(() {
                                        _selectedImage = imageBytes;
                                      });
                                    },
                                    width: 150,
                                    height: 150,
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Submit buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ZSButton(
                                        text: _isSaving ? 'Spremam...' : 'Spremi promjene',
                                        backgroundColor: Colors.green.shade50,
                                        foregroundColor: Colors.green,
                                        borderColor: Colors.grey.shade300,
                                        width: 250,
                                        onPressed: _isSaving ? () {} : _submitProfileUpdate,
                                      ),
                                      
                                      const SizedBox(width: 20),
                                      
                                      ZSButton(
                                        text: 'Odustani',
                                        backgroundColor: Colors.grey.shade100,
                                        foregroundColor: Colors.grey.shade700,
                                        borderColor: Colors.grey.shade300,
                                        width: 250,
                                        onPressed: _isSaving ? () {} : () {
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
  
  void _submitProfileUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        // Get the employee ID from the current user profile
        int? employeeId = _currentUserProfile?['employeeId'];
        
        if (employeeId == null) {
          throw Exception('Employee ID not found');
        }
        
        // Map gender from UI to backend
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
        
        final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
        
        final updatedEmployee = await employeeProvider.updateSelfProfile(
          employeeId,
          _firstNameController.text,
          _lastNameController.text,
          _emailController.text,
          backendGender,
          imageBytes: _selectedImage,
        );
        
        if (updatedEmployee != null) {
          // Refresh the user profile data
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.loadCurrentUserProfile();
          
          // Update the current user profile data and reload the image
          final refreshedProfile = userProvider.currentUserProfile;
          if (refreshedProfile != null) {
            setState(() {
              _currentUserProfile = refreshedProfile;
            });
            
            // Reload the image if there's a new image URL
            String? newProfileImageUrl = refreshedProfile['profileImageUrl'];
            if (newProfileImageUrl != null && newProfileImageUrl.isNotEmpty) {
              await _loadProfileImage(newProfileImageUrl);
            }
          }
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil je uspješno ažuriran!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back
          Navigator.pop(context);
        } else {
          throw Exception('Failed to update profile');
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška prilikom ažuriranja profila: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
