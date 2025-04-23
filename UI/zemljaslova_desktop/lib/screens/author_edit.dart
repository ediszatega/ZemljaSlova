import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/author.dart';
import '../providers/author_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_datetime_picker.dart';

class AuthorEditScreen extends StatefulWidget {
  final Author author;
  
  const AuthorEditScreen({
    super.key,
    required this.author,
  });

  @override
  State<AuthorEditScreen> createState() => _AuthorEditScreenState();
}

class _AuthorEditScreenState extends State<AuthorEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _genreController;
  late TextEditingController _biographyController;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with author data
    _firstNameController = TextEditingController(text: widget.author.firstName);
    _lastNameController = TextEditingController(text: widget.author.lastName);
    _dateOfBirthController = TextEditingController(text: widget.author.dateOfBirth);
    _genreController = TextEditingController(text: widget.author.genre);
    _biographyController = TextEditingController(text: widget.author.biography);
  }

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
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Nazad na pregled autora'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  Text(
                    'Uređivanje autora: ${widget.author.fullName}',
                    style: const TextStyle(
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
                            ZSDatetimePicker(
                              label: 'Datum rođenja',
                              controller: _dateOfBirthController,
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
                            
                            const SizedBox(height: 40),
                            
                            // Submit button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ZSButton(
                                  text: 'Spremi promjene',
                                  backgroundColor: Colors.green.shade50,
                                  foregroundColor: Colors.green,
                                  borderColor: Colors.grey.shade300,
                                  width: 250,
                                  onPressed: _updateAuthor,
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
  
  void _updateAuthor() {
    if (_formKey.currentState!.validate()) {
      final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
      
      authorProvider.updateAuthor(
        widget.author.id,
        _firstNameController.text,
        _lastNameController.text,
        _dateOfBirthController.text.isEmpty ? null : _dateOfBirthController.text,
        _genreController.text.isEmpty ? null : _genreController.text,
        _biographyController.text.isEmpty ? null : _biographyController.text,
      ).then((success) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Autor uspješno ažuriran!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Get the updated author and return to the previous screen
          authorProvider.getAuthorById(widget.author.id).then((updatedAuthor) {
            // Navigate back with the updated author
            Navigator.pop(context, updatedAuthor);
          });
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška prilikom ažuriranja autora: ${authorProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
} 