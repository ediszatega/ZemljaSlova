import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/member_provider.dart';
import '../providers/membership_provider.dart';
import '../utils/authorization.dart';
import '../widgets/mobile_layout.dart';
import '../widgets/zs_button.dart';
import 'register_screen.dart';
import 'membership_purchase_screen.dart';

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
                margin: const EdgeInsets.only(bottom: 18),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/zs_logo_name.png',
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
                            FormBuilderValidators.minLength(8),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        
                        // Login Button
                        _isLoading 
                          ? SizedBox(
                              width: double.infinity,
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
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              paddingVertical: 16,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              borderRadius: 8,
                            ),
                        
                        // Register Link
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text("Nemaš račun? Registruj se"),
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
        // Login successful and check for active membership
        if (mounted) {
          await _checkMembershipAndNavigate();
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

  Future<void> _checkMembershipAndNavigate() async {
    try {
      // Get member data first
      final memberProvider = context.read<MemberProvider>();
      await memberProvider.getMemberByUserId(Authorization.userId!);
      
      if (memberProvider.currentMember != null) {
        // Check for active membership
        final membershipProvider = context.read<MembershipProvider>();
        final hasActiveMembership = await membershipProvider.getActiveMembership(memberProvider.currentMember!.id);
        
        if (hasActiveMembership && membershipProvider.hasActiveMembership) {
          // User has active membership - go to main app
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MobileLayout(),
            ),
            (route) => false,
          );
        } else {
          // User doesn't have active membership - show membership purchase screen
           Navigator.of(context).pushAndRemoveUntil(
             MaterialPageRoute(
               builder: (context) => const MembershipPurchaseScreen(
                 isFromRegistration: false,
                 isFromLogin: true,
               ),
             ),
             (route) => false,
           );
        }
      } else {
        // Fallback - go to main app if member data couldn't be loaded
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MobileLayout(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      // Fallback - go to main app if there's an error
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MobileLayout(),
        ),
        (route) => false,
      );
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