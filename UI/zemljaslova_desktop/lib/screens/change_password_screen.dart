import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/sidebar.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userId;
  
  const ChangePasswordScreen({
    super.key,
    required this.userId,
  });

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
    final userProvider = Provider.of<UserProvider>(context);
    
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
                    label: const Text('Nazad'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Promjena lozinke',
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
                            // Current password field
                            Stack(
                              children: [
                                ZSInput(
                                  controller: _currentPasswordController,
                                  label: 'Trenutna lozinka*',
                                  obscureText: _obscureCurrentPassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Molimo unesite trenutnu lozinku';
                                    }
                                    return null;
                                  },
                                ),
                                Positioned(
                                  right: 16,
                                  top: 42,
                                  child: IconButton(
                                    icon: Icon(
                                      _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureCurrentPassword = !_obscureCurrentPassword;
                                      });
                                    },
                                    splashRadius: 20,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // New password field
                            Stack(
                              children: [
                                ZSInput(
                                  controller: _newPasswordController,
                                  label: 'Nova lozinka*',
                                  obscureText: _obscureNewPassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Molimo unesite novu lozinku';
                                    }
                                    if (value.length < 6) {
                                      return 'Lozinka mora sadržavati najmanje 6 znakova';
                                    }
                                    return null;
                                  },
                                ),
                                Positioned(
                                  right: 16,
                                  top: 42,
                                  child: IconButton(
                                    icon: Icon(
                                      _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewPassword = !_obscureNewPassword;
                                      });
                                    },
                                    splashRadius: 20,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Confirm password field
                            Stack(
                              children: [
                                ZSInput(
                                  controller: _confirmPasswordController,
                                  label: 'Potvrda nove lozinke*',
                                  obscureText: _obscureConfirmPassword,
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
                                Positioned(
                                  right: 16,
                                  top: 42,
                                  child: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                    splashRadius: 20,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Error message
                            if (userProvider.error != null)
                              Container(
                                width: 600,
                                padding: const EdgeInsets.all(12.0),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Success message
                            if (userProvider.successMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            const SizedBox(height: 20),
                            
                            // Submit buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                userProvider.isLoading
                                ? const SizedBox(
                                    width: 250,
                                    child: Center(child: CircularProgressIndicator()),
                                  )
                                : ZSButton(
                                  text: 'Promijeni lozinku',
                                  backgroundColor: Colors.green.shade50,
                                  foregroundColor: Colors.green,
                                  borderColor: Colors.grey.shade300,
                                  width: 250,
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final success = await userProvider.changePassword(
                                        widget.userId,
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
                                            Navigator.pop(context, true);
                                          }
                                        });
                                      }
                                    }
                                  },
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
} 