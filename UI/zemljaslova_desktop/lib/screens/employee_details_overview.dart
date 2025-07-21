import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zemljaslova_desktop/widgets/zs_button.dart';
import '../models/employee.dart';
import '../widgets/sidebar.dart';
import '../providers/user_provider.dart';
import '../providers/employee_provider.dart';
import 'employees_overview.dart';
import 'employee_edit.dart';
import 'change_password_screen.dart';
import '../widgets/permission_guard.dart';

class EmployeeDetailsOverview extends StatefulWidget {
  final Employee employee;
  
  const EmployeeDetailsOverview({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeDetailsOverview> createState() => _EmployeeDetailsOverviewState();
}

class _EmployeeDetailsOverviewState extends State<EmployeeDetailsOverview> {
  late Employee _employee;
  
  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
  }

  Future<void> _handleEmployeeDeleted() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izbriši uposlenika'),
        content: Text(
          'Da li ste sigurni da želite izbrisati uposlenika ${_employee.fullName}?\n\n'
          'Ova akcija će trajno obrisati uposlenika i sve povezane podatke.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Izbriši'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final success = await Provider.of<EmployeeProvider>(context, listen: false)
            .deleteEmployee(_employee.id);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uposlenik je uspješno izbrisan'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/employees',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Greška prilikom brisanja uposlenika'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 44, left: 80.0, right: 80.0, bottom: 44.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Nazad na pregled uposlenika'),
                    ),
                    const SizedBox(height: 24),
                    
                    // Header
                    const Text(
                      'Pregled detalja o uposleniku',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Main content area with profile and details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Profile image
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Center(
                                child: _employee.profileImageUrl != null
                                  ? Image.network(
                                      _employee.profileImageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 120,
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 40),
                        
                        // Right column - User details
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User name and status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _employee.fullName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // User details section
                              const Text(
                                'Detalji o uposleniku',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Detail rows
                              DetailRow(label: 'Email', value: _employee.email),
                              DetailRow(label: 'Pristupni nivo', value: _employee.displayAccessLevel),
                              DetailRow(label: 'Broj obrađenih narudžbi', value: '15'),
                              DetailRow(label: 'Broj riješenih tiketa', value: '8'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Action buttons
                    Column(
                      children: [
                        ZSButton(
                          text: 'Uredi uposlenika',
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue,
                          borderColor: Colors.grey.shade300,
                          width: 410,
                          topPadding: 5,
                          onPressed: () async {
                            final updatedEmployee = await Navigator.of(context).push<Employee>(
                              MaterialPageRoute(
                                builder: (context) => EmployeeEditScreen(employeeId: _employee.id),
                              ),
                            );
                            
                            if (updatedEmployee != null) {
                              setState(() {
                                _employee = updatedEmployee;
                              });
                            }
                          },
                        ),

                        CanChangeUserPasswords(
                          child: ZSButton(
                            text: 'Promijeni lozinku',
                            backgroundColor: Colors.orange.shade50,
                            foregroundColor: Colors.orange,
                            borderColor: Colors.grey.shade300,
                            width: 410,
                            topPadding: 5,
                            onPressed: () async {
                              // Get the UserService from the provider
                              final userService = Provider.of<UserProvider>(context, listen: false).userService;
                              
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider(
                                    create: (_) => UserProvider(userService),
                                    child: ChangePasswordScreen(
                                      userId: _employee.userId,
                                      userName: _employee.fullName,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        CanDeleteEmployees(
                          child: ZSButton(
                            text: 'Obriši uposlenika',
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            borderColor: Colors.grey.shade300,
                            width: 410,
                            topPadding: 5,
                            onPressed: () => _handleEmployeeDeleted(),
                          ),
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
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 