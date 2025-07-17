import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/empty_state.dart';
import '../widgets/pagination_controls_widget.dart';
import 'book_detail_overview.dart';
import 'book_add.dart';

class BooksSellOverview extends StatelessWidget {
  const BooksSellOverview({super.key});

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
            child: BooksContent(),
          ),
        ],
      ),
    );
  }
}

class BooksContent extends StatefulWidget {
  const BooksContent({super.key});

  @override
  State<BooksContent> createState() => _BooksContentState();
}

class _BooksContentState extends State<BooksContent> with WidgetsBindingObserver {
  String _sortOption = 'Naslov (A-Z)';
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Register as an observer to detect when the app regains focus
    WidgetsBinding.instance.addObserver(this);
    _loadBooks();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
      Provider.of<BookProvider>(context, listen: false).refresh(isAuthorIncluded: true);
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
            'Pregled knjiga na prodaju',
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
        // Search using our component
        Expanded(
          child: SearchInput(
            label: 'Pretraži',
            hintText: 'Pretraži knjige',
            borderColor: Colors.grey.shade300,
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
                builder: (context) => const BookAddScreen(),
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
        if (bookProvider.isInitialLoading) {
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
            icon: Icons.shopping_cart,
            title: 'Nema knjiga za prikaz',
            description: 'Trenutno u sistemu nema knjiga za prodaju.\nDodajte novu knjigu da biste počeli.',
          );
        }
        
        // Sort the books list based on the selected option
        final sortedBooks = List<Book>.from(books);
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
        
        return CustomScrollView(
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
                  final book = sortedBooks[index];
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
                childCount: sortedBooks.length,
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
                    itemName: 'knjiga',
                    loadMoreText: 'Učitaj više knjiga',
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(
                child: SizedBox(height: 60),
              ),
          ],
        );
      },
    );
  }
} 