import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/permission_guard.dart';
import 'book_edit.dart';

class BookDetailOverview extends StatefulWidget {
  final Book book;
  
  const BookDetailOverview({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailOverview> createState() => _BookDetailOverviewState();
}

class _BookDetailOverviewState extends State<BookDetailOverview> {
  late Future<Book?> _bookFuture;
  
  @override
  void initState() {
    super.initState();
    // Load fresh book data to ensure we have the latest info including author
    _loadBookData();
  }
  
  void _loadBookData() {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    _bookFuture = bookProvider.getBookById(widget.book.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          const SidebarWidget(),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 44, left: 80.0, right: 80.0),
              child: FutureBuilder<Book?>(
                future: _bookFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final book = snapshot.data ?? widget.book;
                  
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Nazad na pregled knjiga'),
                        ),
                        const SizedBox(height: 24),
                        
                        // Header
                        const Text(
                          'Pregled detalja o knjizi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Main content area with book cover and details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column - Book cover
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 0.7,
                                  child: Center(
                                    child: book.coverImageUrl != null
                                      ? Image.network(
                                          book.coverImageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/no_image.jpg',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.book,
                                              size: 120,
                                              color: Colors.black,
                                            );
                                          },
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 40),
                            
                            // Right column - Book details
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Book title and availability
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          book.title,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16, 
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: book.isAvailable 
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          book.isAvailable ? 'Na stanju' : 'Nije na stanju',
                                          style: TextStyle(
                                            color: book.isAvailable ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Authors
                                  Text(
                                    'Autori: ${book.authorNames}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Price
                                  Text(
                                    'Cijena: ${book.price.toStringAsFixed(2)} KM',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 30),

                                                              // Availability information
                                  const Text(
                                    'Dostupnost',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 10),
                                  
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              color: Colors.black87,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Na stanju',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  '${book.quantityInStock} komada',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.shopping_bag_outlined,
                                              color: Colors.black87,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Prodano',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  '${book.quantitySold} komada',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
                                  
                                  // Book details section
                                  const Text(
                                    'Detalji o knjizi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Detail rows
                                  if (book.description != null && book.description!.isNotEmpty)
                                    DetailRow(label: 'Opis', value: book.description!),
                                  if (book.publisher != null && book.publisher!.isNotEmpty)
                                    DetailRow(label: 'Izdavač', value: book.publisher!),
                                  if (book.dateOfPublish != null && book.dateOfPublish!.isNotEmpty)
                                    DetailRow(label: 'Datum izdavanja', value: book.dateOfPublish!),
                                  if (book.edition != null)
                                    DetailRow(label: 'Izdanje', value: book.edition.toString()),
                                  DetailRow(label: 'Broj stranica', value: book.numberOfPages.toString()),
                                  if (book.bookPurpos != null && book.bookPurpos!.isNotEmpty)
                                    DetailRow(label: 'Namjena', value: book.bookPurpos!),
                                  if (book.dimensions != null && book.dimensions!.isNotEmpty)
                                    DetailRow(label: 'Dimenzije', value: book.dimensions!),
                                  if (book.weight != null)
                                    DetailRow(label: 'Težina', value: '${book.weight} g'),
                                  if (book.genre != null && book.genre!.isNotEmpty)
                                    DetailRow(label: 'Žanr', value: book.genre!),
                                  if (book.binding != null && book.binding!.isNotEmpty)
                                    DetailRow(label: 'Tip korica', value: book.binding!),
                                  if (book.language != null && book.language!.isNotEmpty)
                                    DetailRow(label: 'Jezik', value: book.language!),
                                                                    ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Action buttons
                        Column(
                          children: [
                            ZSButton(
                              text: 'Uredi knjigu',
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: Colors.blue,
                              borderColor: Colors.grey.shade300,
                              width: 410,
                              topPadding: 5,
                              onPressed: () async {
                                final updatedBook = await Navigator.of(context).push<Book>(
                                  MaterialPageRoute(
                                    builder: (context) => BookEditScreen(book: book),
                                  ),
                                );
                                
                                // If we got an updated book back, refresh this screen
                                if (updatedBook != null) {
                                  setState(() {
                                    _loadBookData();
                                  });
                                }
                              },
                            ),
                            
                            ZSButton(
                              text: book.isAvailable ? 'Označi kao nedostupno' : 'Označi kao dostupno',
                              backgroundColor: Colors.white,
                              foregroundColor: book.isAvailable ? Colors.red : Colors.green,
                              borderColor: Colors.grey.shade300,
                              width: 410,
                              topPadding: 5,
                              onPressed: () {},
                            ),
                            
                            CanDeleteBooks(
                              child: ZSButton(
                                text: 'Obriši knjigu',
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red,
                                borderColor: Colors.grey.shade300,
                                width: 410,
                                topPadding: 5,
                                onPressed: () => _showDeleteDialog(),
                              ),
                            ),
                          ],
                        ),
                        // Add some bottom padding to ensure everything is visible when scrolling
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda brisanja'),
          content: Text(
            'Da li ste sigurni da želite obrisati knjigu "${widget.book.title}"?\n\n'
            'Ova akcija se ne može poništiti.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteBook();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _deleteBook() async {
    try {
      final success = await Provider.of<BookProvider>(context, listen: false)
          .deleteBook(widget.book.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Knjiga je uspješno obrisana'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to books overview
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška pri brisanju knjige'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 