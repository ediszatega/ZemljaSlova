import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';

class BooksSellOverviewScreen extends StatefulWidget {
  const BooksSellOverviewScreen({super.key});

  @override
  State<BooksSellOverviewScreen> createState() => _BooksSellOverviewScreenState();
}

class _BooksSellOverviewScreenState extends State<BooksSellOverviewScreen> {
  String _sortOption = 'Naslov (A-Z)';
  final TextEditingController _searchController = TextEditingController();

  // Mock data for demonstration
  final List<Book> _mockBooks = [
    Book(
      id: 1,
      title: 'Na Drini ćuprija',
      price: 25.0,
      coverImageUrl: null,
      authors: [
        Author(
          id: 1,
          firstName: 'Ivo',
          lastName: 'Andrić',
        ),
      ],
      authorIds: [1],
    ),
    Book(
      id: 2,
      title: 'Naslov knjige',
      price: 25.0,
      coverImageUrl: null,
      authors: [
        Author(
          id: 2,
          firstName: 'Ime',
          lastName: 'Prezime',
        ),
      ],
      authorIds: [2],
    ),
    Book(
      id: 3,
      title: 'Naslov knjige',
      price: 25.0,
      coverImageUrl: null,
      authors: [
        Author(
          id: 3,
          firstName: 'Ime',
          lastName: 'Prezime',
        ),
      ],
      authorIds: [3],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Pregled knjiga na prodaju',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          
          // Search bar
          SearchInput(
            controller: _searchController,
            hintText: 'Pretraži knjige',
            borderColor: Colors.grey.shade300,
          ),
          
          const SizedBox(height: 8),
          
          // Toolbar - Sort and Filter
          Row(
            children: [
              // Sort dropdown
              Expanded(
                child: ZSDropdown<String>(
                  label: 'Sortiraj',
                  value: _sortOption,
                  items: const [
                    DropdownMenuItem(value: 'Naslov (A-Z)', child: Text('Naslov (A-Z)')),
                    DropdownMenuItem(value: 'Naslov (Z-A)', child: Text('Naslov (Z-A)')),
                    DropdownMenuItem(value: 'Autor (A-Z)', child: Text('Autor (A-Z)')),
                    DropdownMenuItem(value: 'Cijena (veća)', child: Text('Cijena (veća)')),
                    DropdownMenuItem(value: 'Cijena (manja)', child: Text('Cijena (manja)')),
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
              ),
              const SizedBox(width: 12),
              
              // Filter button
              Expanded(
                child: ZSButton(
                  onPressed: () {
                    // TODO: Implement filter functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filteri će biti implementirani')),
                    );
                  },
                  text: 'Postavi filtre',
                  label: 'Filtriraj',
                  borderColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Books grid
          _buildBooksGrid(),
        ],
      ),
    );
  }
  
  Widget _buildBooksGrid() {
    // Sort the books list based on the selected option
    final sortedBooks = List<Book>.from(_mockBooks);
    switch (_sortOption) {
      case 'Naslov (A-Z)':
        sortedBooks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Naslov (Z-A)':
        sortedBooks.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'Autor (A-Z)':
        sortedBooks.sort((a, b) => a.authorNames.compareTo(b.authorNames));
        break;
      case 'Cijena (veća)':
        sortedBooks.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Cijena (manja)':
        sortedBooks.sort((a, b) => a.price.compareTo(b.price));
        break;
    }

    // Use responsive layout
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate number of columns based on screen width
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.5,
          ),
          itemCount: sortedBooks.length,
          itemBuilder: (context, index) {
            final book = sortedBooks[index];
            return ZSCard.fromBook(
              context,
              book,
              onTap: () {
                // TODO: Navigate to book detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Detalji za: ${book.title}')),
                );
              },
            );
          },
        );
      },
    );
  }
} 