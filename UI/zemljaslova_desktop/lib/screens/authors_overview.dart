import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/author.dart';
import '../providers/author_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import 'author_detail_overview.dart';
import 'author_add.dart';

class AuthorsOverview extends StatelessWidget {
  const AuthorsOverview({super.key});

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
            child: AuthorsContent(),
          ),
        ],
      ),
    );
  }
}

class AuthorsContent extends StatefulWidget {
  const AuthorsContent({super.key});

  @override
  State<AuthorsContent> createState() => _AuthorsContentState();
}

class _AuthorsContentState extends State<AuthorsContent> {
  String _sortOption = 'Ime (A-Z)';
  
  @override
  void initState() {
    super.initState();
    // Load authors data
    Future.microtask(() {
      Provider.of<AuthorProvider>(context, listen: false).fetchAuthors();
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
            'Pregled autora',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Build toolbar
          _buildToolbar(),
          
          const SizedBox(height: 24),
          
          // Authors grid
          Expanded(
            child: _buildAuthorsGrid(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToolbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search using our new component
        Expanded(
          child: SearchInput(
            label: 'Pretraži',
            hintText: 'Pretraži autore',
            borderColor: Colors.grey.shade300,
            onChanged: (value) {
              // TODO: Implement search functionality
              print('Searching for: $value');
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Sort dropdown
        ZSDropdown<String>(
          label: 'Sortiraj',
          value: _sortOption,
          width: 180,
          items: const [
            DropdownMenuItem(value: 'Ime (A-Z)', child: Text('Ime (A-Z)')),
            DropdownMenuItem(value: 'Ime (Z-A)', child: Text('Ime (Z-A)')),
            DropdownMenuItem(value: 'Najnoviji', child: Text('Najnoviji')),
            DropdownMenuItem(value: 'Najstariji', child: Text('Najstariji')),
            DropdownMenuItem(value: 'Žanr', child: Text('Žanr')),
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
        
        // Filter
        ZSButton(
          onPressed: () {},
          text: 'Postavi filtre',
          label: 'Filtriraj',
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
        const SizedBox(width: 16),
        
        // Add button
        ZSButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthorAddScreen(),
              ),
            );
          },
          text: 'Dodaj autora',
          backgroundColor: const Color(0xFFE5FFEE),
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
      ],
    );
  }
  
  Widget _buildAuthorsGrid() {
    return Consumer<AuthorProvider>(
      builder: (ctx, authorProvider, child) {
        if (authorProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (authorProvider.error != null) {
          return Center(
            child: Text(
              'Greška: ${authorProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final authors = authorProvider.authors;
        
        if (authors.isEmpty) {
          return const Center(
            child: Text('Nema autora za prikaz.'),
          );
        }
        
        // Sort the authors list based on the selected option
        final sortedAuthors = List<Author>.from(authors);
        switch (_sortOption) {
          case 'Ime (A-Z)':
            sortedAuthors.sort((a, b) => a.fullName.compareTo(b.fullName));
            break;
          case 'Ime (Z-A)':
            sortedAuthors.sort((a, b) => b.fullName.compareTo(a.fullName));
            break;
          case 'Najnoviji':
            // In a real app, this would sort by creation date
            sortedAuthors.sort((a, b) => b.id.compareTo(a.id));
            break;
          case 'Najstariji':
            // In a real app, this would sort by creation date
            sortedAuthors.sort((a, b) => a.id.compareTo(b.id));
            break;
          case 'Žanr':
            // Sort by genre, with null genres at the end
            sortedAuthors.sort((a, b) {
              if (a.genre == null && b.genre == null) return 0;
              if (a.genre == null) return 1;
              if (b.genre == null) return -1;
              return a.genre!.compareTo(b.genre!);
            });
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
          itemCount: sortedAuthors.length,
          itemBuilder: (context, index) {
            final author = sortedAuthors[index];
            return ZSCard.fromAuthor(
              context,
              author,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthorDetailOverview(
                      author: author,
                    ),
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