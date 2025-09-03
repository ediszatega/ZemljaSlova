import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/zs_button.dart';
import '../models/author.dart';
import '../providers/author_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/permission_guard.dart';
import 'author_edit.dart';

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
                            child: author.imageUrl != null && author.imageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      author.imageUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildFallbackAuthorImage();
                                      },
                                    ),
                                  )
                                : _buildFallbackAuthorImage(),
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
                        onPressed: () async {
                          final updatedAuthor = await Navigator.of(context).push<Author>(
                            MaterialPageRoute(
                              builder: (context) => AuthorEditScreen(author: author),
                            ),
                          );
                          
                          // If we got an updated author back, refresh this screen
                          if (updatedAuthor != null) {
                            // Using Navigator to rebuild the detail screen with new data
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => AuthorDetailOverview(
                                  author: updatedAuthor,
                                ),
                              ),
                            );
                          }
                        },
                      ),

                      CanDeleteAuthors(
                        child: ZSButton(
                          text: 'Obriši autora',
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          borderColor: Colors.grey.shade300,
                          width: 410,
                          topPadding: 5,
                          onPressed: () => _showDeleteDialog(context),
                        ),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda brisanja'),
          content: Text(
            'Da li ste sigurni da želite obrisati autora "${author.fullName}"?\n\n'
            'Ova akcija se ne može poništiti.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAuthor(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _deleteAuthor(BuildContext context) async {
    final success = await Provider.of<AuthorProvider>(context, listen: false)
        .deleteAuthor(author.id);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autor je uspješno obrisan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      if (context.mounted) {
        final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
        String errorMessage = authorProvider.error ?? 'Greška prilikom brisanja autora';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }
  
  Widget _buildFallbackAuthorImage() {
    return const Center(
      child: Icon(
        Icons.person,
        size: 120,
        color: Colors.black,
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