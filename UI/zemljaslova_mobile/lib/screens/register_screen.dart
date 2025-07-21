import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../widgets/zs_button.dart';
import '../utils/password_validator.dart' as custom;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _selectedDate;
  String? _selectedGender;

  final List<String> _genderOptions = ['Muški', 'Ženski'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Registracija'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/zs_logo_name.png',
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kreiraj svoj račun',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Registration Form
              Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // First Name Field
                        FormBuilderTextField(
                          name: "firstName",
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: "Ime",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Ime je obavezno"),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        
                        // Last Name Field
                        FormBuilderTextField(
                          name: "lastName",
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: "Prezime",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Prezime je obavezno"),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        
                        // Email Field
                        FormBuilderTextField(
                          name: "email",
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Email je obavezan"),
                            FormBuilderValidators.email(errorText: "Unesite validan email"),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        
                        // Date of Birth Field
                        FormBuilderDateTimePicker(
                          name: "dateOfBirth",
                          inputType: InputType.date,
                          format: DateFormat('dd.MM.yyyy'),
                          decoration: const InputDecoration(
                            labelText: "Datum rođenja",
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Datum rođenja je obavezan"),
                          ]),
                          onChanged: (value) {
                            setState(() {
                              _selectedDate = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Gender Field
                        FormBuilderDropdown<String>(
                          name: "gender",
                          decoration: const InputDecoration(
                            labelText: "Pol",
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          items: _genderOptions
                              .map((gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ))
                              .toList(),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Pol je obavezan"),
                          ]),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password Field
                        FormBuilderTextField(
                          name: "password",
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Lozinka",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Lozinka je obavezna"),
                            FormBuilderValidators.minLength(8, errorText: "Lozinka mora imati najmanje 8 karaktera"),
                            (value) {
                              if (value != null && !custom.PasswordValidator.isValidPassword(value)) {
                                return custom.PasswordValidator.getPasswordRequirementsMessage();
                              }
                              return null;
                            },
                          ]),
                        ),
                        const SizedBox(height: 16),
                        
                        // Confirm Password Field
                        FormBuilderTextField(
                          name: "confirmPassword",
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: "Potvrdi lozinku",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Potvrda lozinke je obavezna"),
                            (value) {
                              if (value != _passwordController.text) {
                                return "Lozinke se ne poklapaju";
                              }
                              return null;
                            },
                          ]),
                        ),
                        const SizedBox(height: 24),
                        
                        // Register Button
                        Consumer<MemberProvider>(
                          builder: (context, memberProvider, child) {
                            return memberProvider.isLoading 
                              ? SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: const Text("Kreiranje računa...", style: TextStyle(fontSize: 16, color: Colors.white)),
                                  ),
                                )
                              : ZSButton(
                                  text: "Registruj se",
                                  onPressed: () => _handleRegister(memberProvider),
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  paddingVertical: 16,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  borderRadius: 8,
                                );
                          },
                        ),
                        
                        // Login Link
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Već imaš račun? Prijavi se"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister(MemberProvider memberProvider) async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final formData = _formKey.currentState!.value;
    
    // Convert gender to backend format
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

    final success = await memberProvider.registerMember(
      firstName: formData["firstName"],
      lastName: formData["lastName"],
      email: formData["email"],
      password: formData["password"],
      dateOfBirth: _selectedDate!,
      gender: backendGender,
    );

    if (success && mounted) {
      // Show success message and navigate back to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Račun uspješno kreiran! Možete se prijaviti.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(memberProvider.error ?? 'Greška prilikom registracije'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
} 