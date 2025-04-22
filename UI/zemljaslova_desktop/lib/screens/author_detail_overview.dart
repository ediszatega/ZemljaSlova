import 'package:flutter/material.dart';
import '../widgets/zs_button.dart';
import '../models/author.dart';
import '../widgets/sidebar.dart';
import 'authors_overview.dart';

class AuthorDetailOverview extends StatelessWidget {
  final Author author;
  
  const AuthorDetailOverview({
    super.key,
    required this.author,
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
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/authors',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Nazad na pregled autora'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Header
                  const Text(
                    'Pregled detalja o autoru',
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
                              child: const Icon(
                                Icons.person,
                                size: 120,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 40),
                      
                      // Right column - Author details
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Author name
                            Text(
                              author.fullName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Author details section
                            const Text(
                              'Detalji o autoru',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Detail rows
                            if (author.dateOfBirth != null)
                              DetailRow(
                                label: 'Datum rođenja',
                                value: author.dateOfBirth!,
                              ),
                            
                            if (author.genre != null)
                              DetailRow(
                                label: 'Žanr',
                                value: author.genre!,
                              ),
                              
                            const SizedBox(height: 30),
                            
                            // Biography section if available
                            if (author.biography != null) ...[
                              const Text(
                                'Biografija',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Text(
                                author.biography!,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
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
                        text: 'Dodaj knjigu autora',
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green,
                        borderColor: Colors.grey.shade300,
                        width: 410,
                        topPadding: 5,
                        onPressed: () {
                          // TODO: Implement add book functionality
                        },
                      ),
                      
                      ZSButton(
                        text: 'Uredi autora',
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue,
                        borderColor: Colors.grey.shade300,
                        width: 410,
                        topPadding: 5,
                        onPressed: () {
                          // TODO: Implement edit author functionality
                        },
                      ),

                      ZSButton(
                        text: 'Obriši autora',
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        borderColor: Colors.grey.shade300,
                        width: 410,
                        topPadding: 5,
                        onPressed: () {
                          // TODO: Implement delete author functionality
                        },
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