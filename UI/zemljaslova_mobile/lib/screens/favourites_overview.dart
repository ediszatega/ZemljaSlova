import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favourite.dart';
import '../widgets/zs_card.dart';
import '../providers/favourite_provider.dart';
import '../providers/navigation_provider.dart';
import 'book_detail_overview.dart';

class FavouritesOverviewScreen extends StatefulWidget {
  const FavouritesOverviewScreen({super.key});

  @override
  State<FavouritesOverviewScreen> createState() => _FavouritesOverviewScreenState();
}

class _FavouritesOverviewScreenState extends State<FavouritesOverviewScreen> {
  // Mock member ID - in a real app this would come from authentication
  static const int mockMemberId = 3008;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouriteProvider>().fetchFavourites(mockMemberId);
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
        if (favouriteProvider.isLoading) {
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
                      favouriteProvider.fetchFavourites(mockMemberId);
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
          itemCount: favourites.length,
          itemBuilder: (context, index) {
            final favourite = favourites[index];
            final book = favourite.book;
            
            if (book == null) {
              return _buildErrorCard();
            }
            
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