import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/member_provider.dart';
import '../utils/authorization.dart';
import '../widgets/zs_card.dart';
import 'book_detail_overview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Authorization.userId != null) {
        _loadRecommendations(context);
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
          _buildWelcomeBox(context),
          
          const SizedBox(height: 24),

          _buildNavigationTabs(context),

          // Recommendations section (only for logged in users)
          if (Authorization.userId != null) ...[
            const SizedBox(height: 24),
            _buildRecommendationsSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE3F2FD), // Light blue
            Color(0xFFF3E5F5), // Light purple
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dobrodošli,',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'uplovi u svijet knjiga',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'i uživaj u našim uslugama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Image.asset(
                  'assets/books_home.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildNavigationTabs(BuildContext context) {
    return Column(
      children: [
        _buildTabItem(
          context,
          title: 'Pregled knjiga na prodaju',
          icon: Icons.shopping_cart_outlined,
          onTap: () {
            final navigationProvider = Provider.of<MobileNavigationProvider>(context, listen: false);
            navigationProvider.navigateTo(MobileNavigationItem.booksSellOverview);
          },
        ),
        const SizedBox(height: 12),
        _buildTabItem(
          context,
          title: 'Pregled knjiga za iznajmljivanje',
          icon: Icons.book_outlined,
          onTap: () {
            final navigationProvider = Provider.of<MobileNavigationProvider>(context, listen: false);
            navigationProvider.navigateTo(MobileNavigationItem.booksRentOverview);
          },
        ),
        const SizedBox(height: 12),
        _buildTabItem(
          context,
          title: 'Pregled događaja',
          icon: Icons.event_outlined,
          onTap: () {
            final navigationProvider = Provider.of<MobileNavigationProvider>(context, listen: false);
            navigationProvider.navigateTo(MobileNavigationItem.eventsOverview);
          },
        ),
        const SizedBox(height: 12),
        _buildTabItem(
          context,
          title: 'Kupi poklon bon',
          icon: Icons.card_giftcard_outlined,
          onTap: () {
            final navigationProvider = Provider.of<MobileNavigationProvider>(context, listen: false);
            navigationProvider.navigateTo(MobileNavigationItem.voucherPurchase);
          },
        ),
      ],
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Preporučene knjige za vas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => _loadRecommendations(context),
              child: const Text(
                'Osvježi',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer2<RecommendationProvider, MemberProvider>(
          builder: (context, recommendationProvider, memberProvider, child) {
            if (recommendationProvider.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (recommendationProvider.error != null) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.grey.shade600,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nije moguće učitati preporuke',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _loadRecommendations(context),
                      child: const Text('Pokušaj ponovo'),
                    ),
                  ],
                ),
              );
            }
            
            final books = recommendationProvider.recommendedBooks;
            
            if (books.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.recommend_outlined,
                      color: Colors.grey.shade600,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nema dostupnih preporuka',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Još uvijek nemamo personalizirane preporuke za vas',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () => _loadRecommendations(context),
                      child: const Text('Generiraj preporuke'),
                    ),
                  ],
                ),
              );
            }
            
            return SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: ZSCard.fromBook(
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
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _loadRecommendations(BuildContext context) async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);
    
    if (Authorization.userId != null) {
      // Ensure member data is loaded
      if (memberProvider.currentMember == null) {
        await memberProvider.getMemberByUserId(Authorization.userId!);
      }
      
      if (memberProvider.currentMember != null) {
        await recommendationProvider.loadRecommendedBooks(memberProvider.currentMember!.id);
      }
    }
  }
} 