import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/paginated_data_widget.dart';
import '../providers/book_provider.dart';
import 'book_detail_overview.dart';

class BooksSellOverviewScreen extends StatefulWidget {
  const BooksSellOverviewScreen({super.key});

  @override
  State<BooksSellOverviewScreen> createState() => _BooksSellOverviewScreenState();
}

class _BooksSellOverviewScreenState extends State<BooksSellOverviewScreen> with WidgetsBindingObserver {
  String _sortOption = 'Naslov (A-Z)';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear any existing search and reset to default state
      context.read<BookProvider>().clearSearch();
      context.read<BookProvider>().fetchBooks(refresh: true);
      context.read<BookProvider>().setSorting('title', 'asc');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Clear search when leaving the screen
      context.read<BookProvider>().clearSearch();
      _searchController.clear();
    }
  }

  void _handleSortChange(String? value) {
    if (value != null) {
      setState(() {
        _sortOption = value;
      });
      
      String sortBy;
      String sortOrder;
      
      switch (value) {
        case 'Naslov (A-Z)':
          sortBy = 'title';
          sortOrder = 'asc';
          break;
        case 'Naslov (Z-A)':
          sortBy = 'title';
          sortOrder = 'desc';
          break;
        case 'Cijena (manja)':
          sortBy = 'price';
          sortOrder = 'asc';
          break;
        case 'Cijena (veća)':
          sortBy = 'price';
          sortOrder = 'desc';
          break;
        default:
          sortBy = 'title';
          sortOrder = 'asc';
          break;
      }
      
      context.read<BookProvider>().setSorting(sortBy, sortOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<BookProvider>().refresh();
      },
      child: SingleChildScrollView(
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
            label: 'Pretraži',
            hintText: 'Pretraži knjige po naslovu',
            controller: _searchController,
            borderColor: Colors.grey.shade300,
            onChanged: (value) {
              context.read<BookProvider>().setSearchQuery(value);
            },
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
                    DropdownMenuItem(value: 'Cijena (manja)', child: Text('Cijena (manja)')),
                    DropdownMenuItem(value: 'Cijena (veća)', child: Text('Cijena (veća)')),
                  ],
                  onChanged: _handleSortChange,
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
      ),
    );
  }
  
  Widget _buildBooksGrid() {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        return PaginatedDataWidget<Book>(
          provider: bookProvider,
          itemName: 'knjiga',
          loadMoreText: 'Učitaj više knjiga',
          emptyStateIcon: Icons.book_outlined,
          emptyStateMessage: 'Nema dostupnih knjiga',
          gridBuilder: (context, books) {
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return ZSCard.fromBook(
                      context,
                      book,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailOverviewScreen(
                              book: book,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
} 