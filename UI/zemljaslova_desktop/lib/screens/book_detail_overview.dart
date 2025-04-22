import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';

class BookDetailOverview extends StatelessWidget {
  final Book book;
  
  const BookDetailOverview({
    super.key,
    required this.book,
  });

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
              child: SingleChildScrollView(
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
                              
                              // Author
                              Text(
                                'Autor: ${book.author}',
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
                              if (book.authorId != null)
                                DetailRow(label: 'ID autora', value: book.authorId.toString()),
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
                          onPressed: () {},
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
                        
                        ZSButton(
                          text: 'Obriši knjigu',
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          borderColor: Colors.grey.shade300,
                          width: 410,
                          topPadding: 5,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    // Add some bottom padding to ensure everything is visible when scrolling
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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