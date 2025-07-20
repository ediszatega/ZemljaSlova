import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/authorization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                margin: const EdgeInsets.only(bottom: 48),
                child: Column(
                  children: [
                    Icon(
                      Icons.book,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Zemlja Slova',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Login Form
              Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Admin Prijava',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        
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
                            FormBuilderValidators.required(),
                            FormBuilderValidators.email(),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        
                        // Password Field
                        FormBuilderTextField(
                          name: "password",
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Lozinka",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.minLength(6),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text("Prijaviť se", style: TextStyle(fontSize: 16)),
                          ),
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() => _isLoading = true);

    try {
      final formData = _formKey.currentState!.value;
      Authorization.email = formData["email"];
      Authorization.password = formData["password"];

      final authProvider = context.read<AuthProvider>();
      final loginResponse = await authProvider.login();

      if (loginResponse.isSuccess) {
        // Login successful - navigate to main app
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      } else {
        // Handle login failure based on result code
        String errorMessage;
        switch (loginResponse.result) {
          case 1:
            errorMessage = "Korisnik nije pronađen.";
            break;
          case 2:
            errorMessage = "Pogrešna lozinka.";
            break;
          default:
            errorMessage = "Nepoznata greška. Molimo pokušajte ponovo.";
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog("Greška prilikom prijave: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Greška"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}