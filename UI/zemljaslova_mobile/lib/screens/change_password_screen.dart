import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/authorization.dart';
import '../utils/password_validator.dart';
import '../widgets/zs_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Promjena lozinke'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Current password field
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Trenutna lozinka',
                obscureText: _obscureCurrentPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Molimo unesite trenutnu lozinku';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // New password field
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'Nova lozinka',
                obscureText: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                validator: (value) {
                  return PasswordValidator.validatePassword(value ?? '');
                },
              ),
              
              const SizedBox(height: 16),
              
              // Confirm password field
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Potvrda nove lozinke',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Molimo potvrdite novu lozinku';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Lozinke se ne poklapaju';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Error message
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.error != null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              userProvider.error!,
                              style: TextStyle(color: Colors.red.shade700),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              // Success message
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.successMessage != null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              userProvider.successMessage!,
                              style: TextStyle(color: Colors.green.shade700),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: userProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ZSButton(
                                text: 'Promijeni lozinku',
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // Check if userId is available
                                    if (Authorization.userId == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Greška: Korisnički ID nije dostupan. Molimo se ponovno prijavite.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                  
                                    try {
                                      final success = await userProvider.changePassword(
                                        Authorization.userId!,
                                        _currentPasswordController.text,
                                        _newPasswordController.text,
                                        _confirmPasswordController.text,
                                      );
                                      
                                      if (success && mounted) {
                                        _currentPasswordController.clear();
                                        _newPasswordController.clear();
                                        _confirmPasswordController.clear();
                                        
                                        // Automatically close the screen after a delay
                                        Future.delayed(const Duration(seconds: 2), () {
                                          if (mounted) {
                                            Navigator.of(context).pop(true);
                                          }
                                        });
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
                                    }
                                  }
                                },
                                backgroundColor: Colors.blue.shade50,
                                foregroundColor: Colors.blue,
                                borderColor: Colors.blue.shade200,
                                borderWidth: 1,
                                borderRadius: 8,
                                paddingVertical: 16,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                topPadding: 0,
                              ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ZSButton(
                          text: 'Odustani',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.grey.shade700,
                          borderColor: Colors.grey.shade300,
                          borderWidth: 1,
                          borderRadius: 8,
                          paddingVertical: 16,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          topPadding: 0,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade600,
                ),
                onPressed: onToggleVisibility,
              ),
              errorStyle: const TextStyle(
                fontSize: 12,
                height: 1.2,
              ),
              errorMaxLines: 3,
            ),
          ),
        ),
      ],
    );
  }
} 