import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favourite.dart';
import '../models/book.dart';
import '../widgets/zs_card.dart';
import '../providers/favourite_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/member_provider.dart';
import '../providers/book_provider.dart';
import '../utils/authorization.dart';
import 'book_detail_overview.dart';

class FavouritesOverviewScreen extends StatefulWidget {
  const FavouritesOverviewScreen({super.key});

  @override
  State<FavouritesOverviewScreen> createState() => _FavouritesOverviewScreenState();
}

class _FavouritesOverviewScreenState extends State<FavouritesOverviewScreen> {
  List<Book> _favouriteBooksWithAuthors = [];
  bool _isLoadingBooks = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavourites();
    });
  }

  void _loadFavourites() {
    if (Authorization.userId != null) {
      final memberProvider = context.read<MemberProvider>();
      final favouriteProvider = context.read<FavouriteProvider>();
      
      memberProvider.getMemberByUserId(Authorization.userId!).then((success) {
        if (success && memberProvider.currentMember != null) {
          favouriteProvider.fetchFavourites(memberProvider.currentMember!.id).then((_) {
            _loadFavouriteBooksWithAuthors();
          });
        }
      });
    }
  }

  void _loadFavouriteBooksWithAuthors() {
    final favouriteProvider = context.read<FavouriteProvider>();
    final bookProvider = context.read<BookProvider>();
    
    if (favouriteProvider.favourites.isEmpty) {
      setState(() {
        _favouriteBooksWithAuthors = [];
      });
      return;
    }
    
    setState(() {
      _isLoadingBooks = true;
    });
    
    // Get all book IDs from favourites
    final bookIds = favouriteProvider.favourites
        .where((f) => f.book != null)
        .map((f) => f.book!.id)
        .toList();
    
    // Fetch all books with authors in one call (no pagination, get all)
    bookProvider.fetchBooks(isAuthorIncluded: true, refresh: true).then((_) {
      if (mounted) {
        // Filter to only include favourited books
        final allBooks = bookProvider.books;
        final favouriteBooks = allBooks.where((book) => bookIds.contains(book.id)).toList();
        
        setState(() {
          _favouriteBooksWithAuthors = favouriteBooks;
          _isLoadingBooks = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoadingBooks = false;
        });
      }
    });
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
            'Moji favoriti',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Favourites grid
          _buildFavouritesGrid(),
        ],
      ),
    );
  }
  
  Widget _buildFavouritesGrid() {
    return Consumer<FavouriteProvider>(
      builder: (context, favouriteProvider, child) {
        if (favouriteProvider.isLoading || _isLoadingBooks) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(64.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (favouriteProvider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Greška pri učitavanju favorita',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _loadFavourites();
                    },
                    child: const Text('Pokušaj ponovo'),
                  ),
                ],
              ),
            ),
          );
        }

        if (favouriteProvider.favourites.isEmpty) {
          return _buildEmptyState();
        }

        return _buildFavouritesList(favouriteProvider.favourites);
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nemate omiljene knjige',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dodajte knjige u favorite da biste ih lakše pronašli ovdje',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to books overview
                final navigationProvider = Provider.of<MobileNavigationProvider>(context, listen: false);
                navigationProvider.navigateToBottomNavItem(MobileNavigationItem.booksSellOverview, context);
              },
              icon: const Icon(Icons.book),
              label: const Text('Pregled knjiga'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFavouritesList(List<Favourite> favourites) {
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
          itemCount: _favouriteBooksWithAuthors.length,
          itemBuilder: (context, index) {
            final book = _favouriteBooksWithAuthors[index];
            
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
  }
  
  Widget _buildErrorCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Greška pri učitavanju knjige',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 