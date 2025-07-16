import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/cart_item.dart';
import '../providers/book_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favourite_provider.dart';
import '../widgets/zs_button.dart';
import '../widgets/top_branding.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/snackbar_util.dart';

class BookDetailOverviewScreen extends StatefulWidget {
  final Book book;
  
  const BookDetailOverviewScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailOverviewScreen> createState() => _BookDetailOverviewScreenState();
}

class _BookDetailOverviewScreenState extends State<BookDetailOverviewScreen> {
  late Future<Book?> _bookFuture;
  
  @override
  void initState() {
    super.initState();
    // Load fresh book data to ensure we have the latest info including author
    _loadBookData();
    // Load favourites for the current user
    _loadFavouriteStatus();
  }
  
  void _loadBookData() {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    _bookFuture = bookProvider.getBookById(widget.book.id);
  }
  
  void _loadFavouriteStatus() {
    const mockMemberId = 3008; // In a real app, get from authentication
    final favouriteProvider = Provider.of<FavouriteProvider>(context, listen: false);
    favouriteProvider.fetchFavourites(mockMemberId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const TopBranding(),
          Expanded(
            child: FutureBuilder<Book?>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final book = snapshot.data ?? widget.book;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover and basic info
                _buildBookHeader(book),
                
                const SizedBox(height: 8),

                // Action buttons
                _buildActionButtons(book),

                const SizedBox(height: 30),
                
                // Book details section
                _buildBookDetailsSection(book),
                
                const SizedBox(height: 24),
                
                // Description section
                _buildDescriptionSection(book.description!),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      ),
      const BottomNavigation(),
        ],
      ),
    );
  }
  
  Widget _buildBookHeader(Book book) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                height: 400,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                clipBehavior: Clip.antiAlias,
                child: book.coverImageUrl != null
                    ? Image.network(
                        book.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackImage();
                        },
                      )
                    : _buildFallbackImage(),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Consumer<FavouriteProvider>(
                  builder: (context, favouriteProvider, child) {
                    final isFavourite = favouriteProvider.isFavourite(book.id);
                    
                    return GestureDetector(
                      onTap: () async {
                        const mockMemberId = 3008; // In a real app, get from authentication
                        await favouriteProvider.toggleFavourite(mockMemberId, book.id);
                        
                        if (mounted) {
                          final isNowFavourite = favouriteProvider.isFavourite(book.id);
                          SnackBarUtil.showTopSnackBar(
                            context,
                            isNowFavourite 
                              ? 'Knjiga je dodana u favourite!'
                              : 'Knjiga je uklonjena iz favorita!',
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavourite ? Icons.favorite : Icons.favorite_border,
                          color: isFavourite ? Colors.red : Colors.grey,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${book.price.toStringAsFixed(2)} KM',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookDetailsSection(Book book) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalji o knjizi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Detail rows
          _DetailRow(label: 'Autor', value: book.authorNames),
          if (book.genre != null && book.genre!.isNotEmpty)
            _DetailRow(label: 'Žanr', value: book.genre!),
          if (book.dateOfPublish != null && book.dateOfPublish!.isNotEmpty)
            _DetailRow(label: 'Godina izdavanja', value: book.dateOfPublish!),
          _DetailRow(label: 'Broj stranica', value: book.numberOfPages.toString()),
          if (book.weight != null)
            _DetailRow(label: 'Težina', value: '${book.weight!.toStringAsFixed(0)}g'),
          if (book.dimensions != null && book.dimensions!.isNotEmpty)
            _DetailRow(label: 'Dimenzije', value: book.dimensions!),
          if (book.binding != null && book.binding!.isNotEmpty)
            _DetailRow(label: 'Uvez', value: book.binding!),
          if (book.language != null && book.language!.isNotEmpty)
            _DetailRow(label: 'Jezik', value: book.language!),
        ],
      ),
    );
  }
  
  Widget _buildDescriptionSection(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kratak opis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ExpandableDescription(description: description),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(Book book) {
    return Column(
        children: [
          ZSButton(
            text: 'Dodaj u korpu',
            backgroundColor: const Color(0xFF28A745),
            foregroundColor: Colors.white,
            borderColor: const Color(0xFF28A745),
            onPressed: () {
              _addBookToCart(book);
            },
          ),
          const SizedBox(height: 12),
          ZSButton(
            text: 'Pokloni knjigu',
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.blue.shade700,
            borderColor: Colors.blue.shade300,
            onPressed: () {
              // TODO: Implement gift a book
          },
        ),
      ],
    );
  }
  
  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.book,
        size: 60,
        color: Colors.black54,
      ),
    );
  }

  void _addBookToCart(Book book) {
    final cartItemId = 'book_${book.id}';
    
    final cartItem = CartItem(
      id: cartItemId,
      title: book.title,
      price: book.price,
      quantity: 1,
      type: CartItemType.book,
    );

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(cartItem);

    SnackBarUtil.showTopSnackBar(context, 'Knjiga je dodana u korpu! Da biste završili kupovinu otvorite korpu.');
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _DetailRow({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String description;
  
  const _ExpandableDescription({
    required this.description,
  });
  
  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isExpanded || widget.description.length <= 100
              ? widget.description 
              : '${widget.description.substring(0, 100)}...',
          style: const TextStyle(fontSize: 14),
        ),
        if (widget.description.length > 100)
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Prikaži manje' : 'Prikaži više',
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
} 