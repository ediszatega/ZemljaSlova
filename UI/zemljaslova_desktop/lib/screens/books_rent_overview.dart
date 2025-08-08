import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/book_filters.dart';
import '../providers/book_provider.dart';
import '../providers/author_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/empty_state.dart';
import '../widgets/pagination_controls_widget.dart';
import '../widgets/search_loading_indicator.dart';
import '../widgets/filter_dialog.dart';
import '../utils/filter_configurations.dart';
import 'book_detail_overview.dart';
import 'book_add.dart';

class BooksRentOverview extends StatelessWidget {
  const BooksRentOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          SidebarWidget(),
          
          // Main content
          Expanded(
            child: BooksRentContent(),
          ),
        ],
      ),
    );
  }
}

class BooksRentContent extends StatefulWidget {
  const BooksRentContent({super.key});

  @override
  State<BooksRentContent> createState() => _BooksRentContentState();
}

class _BooksRentContentState extends State<BooksRentContent> with WidgetsBindingObserver {
  String _sortOption = 'Naslov (A-Z)';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBooks();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().setSorting('title', 'asc');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadBooks();
    }
  }

  void _loadBooks() {
    // Load books data using pagination
    Future.microtask(() {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      // Initialize for rent books
      bookProvider.initializeForBookPurpose(BookPurpose.rent);
      bookProvider.clearFilters();
      bookProvider.clearSearch();
      bookProvider.refresh(isAuthorIncluded: true);
    });
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

  void _showFiltersDialog() {
    context.read<AuthorProvider>().refresh();
    
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        title: 'Filteri za knjige za iznajmljivanje',
        fields: FilterConfigurations.getBookFilters(context),
        initialValues: context.read<BookProvider>().filters.toMap(),
        onApplyFilters: (values) {
          final filters = BookFilters.fromMap(values);
          context.read<BookProvider>().setFilters(filters);
        },
        onClearFilters: () {
          context.read<BookProvider>().clearFilters();
        },
      ),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0, left: 80.0, right: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Pregled knjiga za iznajmljivanje',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Build toolbar
          _buildToolbar(),
          
          const SizedBox(height: 24),
          
          // Books grid
          Expanded(
            child: _buildBooksGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search 
        Expanded(
          child: SearchInput(
            label: 'Pretraži',
            hintText: 'Pretraži knjige',
            controller: _searchController,
            borderColor: Colors.grey.shade300,
            onChanged: (value) {
              context.read<BookProvider>().setSearchQuery(value);
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
            DropdownMenuItem(value: 'Naslov (A-Z)', child: Text('Naslov (A-Z)')),
            DropdownMenuItem(value: 'Naslov (Z-A)', child: Text('Naslov (Z-A)')),
            DropdownMenuItem(value: 'Cijena (manja)', child: Text('Cijena (manja)')),
            DropdownMenuItem(value: 'Cijena (veća)', child: Text('Cijena (veća)')),
          ],
          onChanged: (value) {
            _handleSortChange(value);
          },
          borderColor: Colors.grey.shade300,
        ),
        const SizedBox(width: 16),
        
        // Filter
        Consumer<BookProvider>(
          builder: (context, bookProvider, child) {
            final hasActiveFilters = bookProvider.filters.hasActiveFilters;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ZSButton(
                  onPressed: () {
                    _showFiltersDialog();
                  },
                  text: hasActiveFilters ? 'Filteri aktivni (${_getActiveFilterCount(bookProvider.filters)})' : 'Postavi filtre',
                  label: 'Filtriraj',
                  backgroundColor: hasActiveFilters ? const Color(0xFFE3F2FD) : Colors.white,
                  foregroundColor: hasActiveFilters ? Colors.blue : Colors.black,
                  borderColor: hasActiveFilters ? Colors.blue : Colors.grey.shade300,
                  width: 180,
                ),
                if (hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 40,
                    child: IconButton(
                      onPressed: () {
                        bookProvider.clearFilters();
                      },
                      icon: const Icon(Icons.clear, color: Colors.red),
                      tooltip: 'Očisti filtre',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(width: 16),
        
        // Add button
        ZSButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookAddScreen(bookPurpose: BookPurpose.rent),
              ),
            ).then((_) {
              // Refresh books when returning from add screen
              _loadBooks();
            });
          },
          text: 'Dodaj knjigu',
          backgroundColor: const Color(0xFFE5FFEE),
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
      ],
    );
  }

  Widget _buildBooksGrid() {
    return Consumer<BookProvider>(
      builder: (ctx, bookProvider, child) {
        if (bookProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (bookProvider.error != null && bookProvider.books.isEmpty) {
          return Center(
            child: Text(
              'Greška: ${bookProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final books = bookProvider.books;
        
        if (books.isEmpty) {
          return const EmptyState(
            icon: Icons.book_outlined,
            title: 'Nema knjiga za prikaz',
            description: 'Trenutno u sistemu nema knjiga za iznajmljivanje.\nDodajte novu knjigu da biste počeli.',
          );
        }
        
        return Stack(
          children: [
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 100),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Books grid
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 40,
                      mainAxisSpacing: 40,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final book = books[index];
                        return ZSCard.fromBook(
                          context,
                          book,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailOverview(
                                  book: book,
                                ),
                              ),
                            ).then((_) {
                              _loadBooks();
                            });
                          },
                        );
                      },
                      childCount: books.length,
                    ),
                  ),
                  
                  if (bookProvider.hasMoreData || bookProvider.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 40),
                        child: PaginationControlsWidget(
                          currentItemCount: bookProvider.books.length,
                          totalCount: bookProvider.totalCount,
                          hasMoreData: bookProvider.hasMoreData,
                          isLoadingMore: bookProvider.isLoadingMore,
                          onLoadMore: () => bookProvider.loadMore(),
                          currentPageSize: bookProvider.pageSize,
                          onPageSizeChanged: (newSize) => bookProvider.setPageSize(newSize),
                          itemName: 'knjiga za iznajmljivanje',
                          loadMoreText: 'Učitaj više knjiga',
                        ),
                      ),
                    )
                  else
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 60),
                    ),
                ],
              ),
            ),
            
            // Search loading indicator
            SearchLoadingIndicator(
              isVisible: bookProvider.isUpdating,
              text: 'Pretražujem knjige...',
              top: 20,
            ),
          ],
        );
      },
    );
  }
} 