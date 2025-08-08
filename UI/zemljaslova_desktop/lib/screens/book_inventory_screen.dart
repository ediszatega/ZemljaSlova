import 'package:flutter/material.dart';
import '../models/book_transaction.dart';
import '../services/inventory_service.dart';
import '../services/api_service.dart';
import '../widgets/inventory_screen.dart';

class BookInventoryScreen extends StatelessWidget {
  final int bookId;
  final String bookTitle;
  final bool isForRent;
  
  const BookInventoryScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    this.isForRent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InventoryScreen<BookTransaction>(
      itemId: bookId,
      itemTitle: bookTitle,
      inventoryService: InventoryService<BookTransaction>(
        ApiService(),
        'BookTransaction/book',
        BookTransaction.fromJson,
      ),
      itemLabel: 'knjiga',
      sellButtonText: isForRent ? 'Ukloni knjigu' : 'Prodaj knjige',
      sellSuccessMessage: isForRent ? 'Knjige uspješno uklonjene' : 'Knjige uspješno prodane',
      insufficientStockMessage: 'Nema dovoljno knjiga na stanju',
      isForRent: isForRent,
    );
  }
} 