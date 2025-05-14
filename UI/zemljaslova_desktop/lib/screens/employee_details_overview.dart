import 'package:flutter/material.dart';
import 'package:zemljaslova_desktop/widgets/zs_button.dart';
import '../models/employee.dart';
import '../widgets/sidebar.dart';
import 'employees_overview.dart';

class EmployeeDetailsOverview extends StatelessWidget {
  final Employee employee;
  
  const EmployeeDetailsOverview({
    super.key,
    required this.employee,
  });

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
                              child: employee.profileImageUrl != null
                                ? Image.network(
                                    employee.profileImageUrl!,
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
                                  employee.fullName,
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
                            DetailRow(label: 'Email', value: employee.email),
                            DetailRow(label: 'Pristupni nivo', value: employee.accessLevel),
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
                        onPressed: () {},
                      ),

                      ZSButton(
                        text: 'Obriši uposlenika',
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        borderColor: Colors.grey.shade300,
                        width: 410,
                        topPadding: 5,
                        onPressed: () {},
                      ),
                    ],
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