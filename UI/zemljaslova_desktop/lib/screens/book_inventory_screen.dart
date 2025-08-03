import 'package:flutter/material.dart';
import '../models/book_transaction.dart';
import '../services/inventory_service.dart';
import '../services/api_service.dart';
import '../widgets/inventory_screen.dart';

class BookInventoryScreen extends StatelessWidget {
  final int bookId;
  final String bookTitle;
  
  const BookInventoryScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
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
      sellButtonText: 'Prodaj knjige',
      sellSuccessMessage: 'Knjige uspješno prodane',
      insufficientStockMessage: 'Nema dovoljno knjiga na stanju',
    );
  }
} 