import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/authorization.dart';
import '../widgets/zs_button.dart';

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
  bool _obscurePassword = true;

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
                margin: const EdgeInsets.only(bottom: 28),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/zs_logo_name.png',
                      height: 200,
                      fit: BoxFit.contain,
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
                          'Prijava',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),

                        // Email Field
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: FormBuilderTextField(
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
                        ),
                        const SizedBox(height: 16),
                        
                        // Password Field
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: FormBuilderTextField(
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
                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(6),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Login Button
                        _isLoading 
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text("Učitavanje...", style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            )
                          : ZSButton(
                              text: "Prijavi se",
                              onPressed: () => _handleLogin(),
                              width: MediaQuery.of(context).size.width * 0.5,
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              paddingVertical: 16,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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