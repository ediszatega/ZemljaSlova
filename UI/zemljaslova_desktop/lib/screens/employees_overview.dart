import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/employee_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../screens/employee_details_overview.dart';

class EmployeesOverview extends StatelessWidget {
  const EmployeesOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          // Sidebar
          SidebarWidget(),
          
          // Main content
          Expanded(
            child: EmployeesContent(),
          ),
        ],
      ),
    );
  }
}

class EmployeesContent extends StatefulWidget {
  const EmployeesContent({super.key});

  @override
  State<EmployeesContent> createState() => _EmployeesContentState();
}

class _EmployeesContentState extends State<EmployeesContent> {
  String _sortOption = 'Ime (A-Z)';
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<EmployeeProvider>(context, listen: false).fetchEmployees(isUserIncluded: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0, left: 80.0, right: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Pregled uposlenika',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Build toolbar
          _buildToolbar(),
          
          const SizedBox(height: 24),
          
          // Employees grid
          Expanded(
            child: _buildEmployeesGrid(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToolbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: SearchInput(
            label: 'Pretraži',
            hintText: 'Pretraži uposlenike',
            borderColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 16),
        
        ZSDropdown<String>(
          label: 'Sortiraj',
          value: _sortOption,
          width: 180,
          items: const [
            DropdownMenuItem(value: 'Ime (A-Z)', child: Text('Ime (A-Z)')),
            DropdownMenuItem(value: 'Ime (Z-A)', child: Text('Ime (Z-A)')),
            DropdownMenuItem(value: 'Status', child: Text('Status')),
            DropdownMenuItem(value: 'Pristupni nivo', child: Text('Pristupni nivo')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _sortOption = value;
              });
            }
          },
          borderColor: Colors.grey.shade300,
        ),
        const SizedBox(width: 16),
        
        ZSButton(
          onPressed: () {},
          text: 'Postavi filtre',
          label: 'Filtriraj',
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
        const SizedBox(width: 16),
        
        ZSButton(
          onPressed: () {
            // TODO: Navigate to employee add screen
          },
          text: 'Dodaj uposlenika',
          backgroundColor: const Color(0xFFE5FFEE),
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
      ],
    );
  }
  
  Widget _buildEmployeesGrid() {
    return Consumer<EmployeeProvider>(
      builder: (ctx, employeeProvider, child) {
        if (employeeProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (employeeProvider.error != null) {
          return Center(
            child: Text(
              'Greška: ${employeeProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final employees = employeeProvider.employees;
        
        if (employees.isEmpty) {
          return const Center(
            child: Text('Nema uposlenika za prikaz.'),
          );
        }
        
        // Sort the employees list based on the selected option
        final sortedEmployees = List<Employee>.from(employees);
        switch (_sortOption) {
          case 'Ime (A-Z)':
            sortedEmployees.sort((a, b) => a.fullName.compareTo(b.fullName));
            break;
          case 'Ime (Z-A)':
            sortedEmployees.sort((a, b) => b.fullName.compareTo(a.fullName));
            break;
          case 'Status':
            // Sort active users first
            sortedEmployees.sort((a, b) => b.isActive == a.isActive ? 0 : (b.isActive ? 1 : -1));
            break;
          case 'Pristupni nivo':
            sortedEmployees.sort((a, b) => a.accessLevel.compareTo(b.accessLevel));
            break;
        }
        
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 40,
            mainAxisSpacing: 40,
            childAspectRatio: 0.7,
          ),
          itemCount: sortedEmployees.length,
          itemBuilder: (context, index) {
            final employee = sortedEmployees[index];
            return ZSCard.fromEmployee(
              context,
              employee,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeDetailsOverview(employee: employee),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
} 