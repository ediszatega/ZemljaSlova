import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/author_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_date_picker.dart';
import '../widgets/image_picker_widget.dart';

class AuthorAddScreen extends StatefulWidget {
  const AuthorAddScreen({super.key});

  @override
  State<AuthorAddScreen> createState() => _AuthorAddScreenState();
}

class _AuthorAddScreenState extends State<AuthorAddScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _biographyController = TextEditingController();
  
  Uint8List? _selectedImage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _genreController.dispose();
    _biographyController.dispose();
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
                        '/authors',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Nazad na pregled autora'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Dodavanje novog autora',
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
                                  return 'Unesite ime autora';
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
                                  return 'Unesite prezime autora';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Date of birth field with datepicker
                            ZSDatePicker(
                              label: 'Datum rođenja',
                              controller: _dateOfBirthController,
                              firstDate: DateTime(1500),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Genre field
                            ZSInput(
                              label: 'Žanr',
                              controller: _genreController,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Biography field
                            ZSInput(
                              label: 'Biografija',
                              controller: _biographyController,
                              maxLines: 5,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Image picker
                            ImagePickerWidget(
                              label: 'Slika autora',
                              width: 200,
                              height: 250,
                              onImageSelected: (imageBytes) {
                                setState(() {
                                  _selectedImage = imageBytes;
                                });
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
                                  onPressed: _saveAuthor,
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
                                      '/authors',
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
  
  void _saveAuthor() {
    if (_formKey.currentState!.validate()) {
      final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
      
      authorProvider.addAuthor(
        _firstNameController.text,
        _lastNameController.text,
        _dateOfBirthController.text.isEmpty ? null : _dateOfBirthController.text,
        _genreController.text.isEmpty ? null : _genreController.text,
        _biographyController.text.isEmpty ? null : _biographyController.text,
        imageBytes: _selectedImage,
      ).then((success) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Autor uspješno dodan!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to authors list
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/authors',
            (route) => false,
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška prilikom dodavanja autora: ${authorProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
} 