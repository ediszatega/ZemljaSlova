import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/book_filters.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/paginated_data_widget.dart';
import '../widgets/filter_dialog.dart';
import '../utils/filter_configurations.dart';
import '../providers/book_provider.dart';
import '../providers/favourite_provider.dart';
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
      // Initialize for sell books - this ensures we only see books for sale
      final bookProvider = context.read<BookProvider>();
      bookProvider.initializeForBookPurpose(BookPurpose.sell);
      bookProvider.clearSearch();
      bookProvider.clearFilters();
      bookProvider.fetchBooks(refresh: true);
      bookProvider.setSorting('title', 'asc');
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
              Consumer<BookProvider>(
                builder: (context, bookProvider, child) {
                  final hasActiveFilters = bookProvider.filters.hasActiveFilters;
                  return Expanded(
                    child: ZSButton(
                      onPressed: () => _showFiltersDialog(),
                      text: hasActiveFilters ? 'Filteri aktivni (${_getActiveFilterCount(bookProvider.filters)})' : 'Postavi filtre',
                      label: 'Filtriraj',
                      backgroundColor: hasActiveFilters ? const Color(0xFFE3F2FD) : Colors.white,
                      foregroundColor: hasActiveFilters ? Colors.blue : Colors.black,
                      borderColor: hasActiveFilters ? Colors.blue : Colors.grey.shade300,
                    ),
                  );
                },
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
  
  void _showFiltersDialog() {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          title: 'Filtriraj knjige',
          fields: FilterConfigurations.getBookFilters(context),
          initialValues: bookProvider.filters.toMap(),
          onApplyFilters: (Map<String, dynamic> filters) {
            final bookFilters = BookFilters.fromMap(filters);
            bookProvider.setFilters(bookFilters);
          },
          onClearFilters: () {
            bookProvider.clearFilters();
          },
        );
      },
    );
  }

  int _getActiveFilterCount(BookFilters filters) {
    int count = 0;
    if (filters.minPrice != null) count++;
    if (filters.maxPrice != null) count++;
    if (filters.authorId != null) count++;
    if (filters.isAvailable != null) count++;
    return count;
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
            return Consumer<FavouriteProvider>(
              builder: (context, favouriteProvider, child) {
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
                          isFavourite: favouriteProvider.isFavourite(book.id),
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
      },
    );
  }
} 