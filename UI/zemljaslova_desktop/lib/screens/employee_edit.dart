import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../models/employee.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_dropdown.dart';

class EmployeeEditScreen extends StatefulWidget {
  final int employeeId;
  
  const EmployeeEditScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<EmployeeEditScreen> createState() => _EmployeeEditScreenState();
}

class _EmployeeEditScreenState extends State<EmployeeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  String? _selectedGender;
  final List<String> _genderOptions = ['Muški', 'Ženski'];
  
  String? _selectedAccessLevel;
  final List<String> _accessLevelOptions = ['Admin', 'Uposlenik'];
  
  bool _isLoading = true;
  Employee? _employee;

  @override
  void initState() {
    super.initState();
    _selectedAccessLevel = 'Uposlenik';
    _loadEmployeeData();
  }
  
  Future<void> _loadEmployeeData() async {
    setState(() {
      _isLoading = true;
    });
    
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    
    try {
      final employee = await employeeProvider.getEmployeeById(widget.employeeId);
      
      if (employee != null) {
        
        setState(() {
          _employee = employee;
          
          _firstNameController.text = employee.firstName;
          _lastNameController.text = employee.lastName;
          _emailController.text = employee.email;
          
          switch (employee.gender?.toLowerCase()) {
            case 'male':
              _selectedGender = 'Muški';
              break;
            case 'female':
              _selectedGender = 'Ženski';
              break;
            default:
              _selectedGender = employee.gender;
          }
          
          String originalAccessLevel = employee.accessLevel;
          switch (originalAccessLevel.toLowerCase()) {
            case 'admin':
              _selectedAccessLevel = 'Admin';
              break;
            case 'employee':
              _selectedAccessLevel = 'Uposlenik';
              break;
            default:
              _selectedAccessLevel = 'Uposlenik';
          }
          
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uposlenik nije pronađen'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška prilikom učitavanja uposlenika: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
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
                    label: const Text('Nazad na pregled uposlenika'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Uređivanje uposlenika',
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
                                        return 'Unesite ime uposlenika';
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
                                        return 'Unesite prezime uposlenika';
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
                                        return 'Unesite email uposlenika';
                                      }
                                      
                                      // Simple email validation
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
                                  
                                  // Access level dropdown
                                  ZSDropdown<String?>(
                                    label: 'Pristupni nivo*',
                                    value: _selectedAccessLevel,
                                    items: _accessLevelOptions.map((level) => 
                                      DropdownMenuItem<String?>(
                                        value: level,
                                        child: Text(level),
                                      )
                                    ).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedAccessLevel = value;
                                      });
                                    },
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Submit buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ZSButton(
                                        text: 'Spremi promjene',
                                        backgroundColor: Colors.green.shade50,
                                        foregroundColor: Colors.green,
                                        borderColor: Colors.grey.shade300,
                                        width: 250,
                                        onPressed: _submitEmployeeUpdate,
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
  
  void _submitEmployeeUpdate() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccessLevel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Odaberite pristupni nivo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Update the employee
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      
      setState(() {
        _isLoading = true;
      });
      
      String accessLevel;
      switch (_selectedAccessLevel) {
        case 'Admin':
          accessLevel = 'admin';
          break;
        case 'Uposlenik':
          accessLevel = 'employee';
          break;
        default:
          accessLevel = 'employee';
      }
      
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
      
      employeeProvider.updateEmployee(
        widget.employeeId,
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        accessLevel,
        backendGender,
      ).then((employee) {
        setState(() {
          _isLoading = false;
        });
        
        if (employee != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(employeeProvider.error != null 
                ? 'Uposlenik je ažuriran, ali: ${employeeProvider.error}'
                : 'Uposlenik je uspješno ažuriran!'),
              backgroundColor: employeeProvider.error != null ? Colors.orange : Colors.green,
            ),
          );
          
          // Navigate back with the updated employee
          Navigator.pop(context, employee);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška prilikom ažuriranja uposlenika: ${employeeProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
} 