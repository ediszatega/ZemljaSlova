import 'package:flutter/material.dart';
import '../models/book.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get books => [..._books];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 50));
      
      final List<Map<String, dynamic>> booksData = [
        {
          'id': 1,
          'title': 'Na Drini ćuprija',
          'author': 'Ivo Andrić',
          'price': 25.0,
          'coverImageUrl': 'https://knjige.ba/media/catalog/product/cache/e4d64343b1bc593f1c5348fe05efa4a6/i/v/ivo-andri---na-drini-uprija.jpg',
          'isAvailable': true,
          'quantityInStock': 5,
          'quantitySold': 12,
        },
        {
          'id': 2,
          'title': 'Tvrđava',
          'author': 'Meša Selimović',
          'price': 22.0,
          'coverImageUrl': null,
          'isAvailable': true,
          'quantityInStock': 8,
          'quantitySold': 5,
        },
        {
          'id': 3,
          'title': 'Derviš i smrt - dugačak naslov za testiranje preklapanja teksta i raspored elemenata',
          'author': 'Meša Selimović',
          'price': 24.0,
          'coverImageUrl': null,
          'isAvailable': false,
          'quantityInStock': 0,
          'quantitySold': 15,
        },
        {
          'id': 4,
          'title': 'Prokleta avlija',
          'author': 'Ivo Andrić',
          'price': 18.0,
          'coverImageUrl': null,
          'isAvailable': true,
          'quantityInStock': 3,
          'quantitySold': 7,
        },
        {
          'id': 5,
          'title': 'Ex Ponto',
          'author': 'Ivo Andrić',
          'price': 17.0,
          'coverImageUrl': null,
          'isAvailable': true,
          'quantityInStock': 6,
          'quantitySold': 4,
        },
        {
          'id': 6,
          'title': 'Sjećanja',
          'author': 'Mak Dizdar',
          'price': 20.0,
          'coverImageUrl': null,
          'isAvailable': false,
          'quantityInStock': 0,
          'quantitySold': 10,
        },
        {
          'id': 7,
          'title': 'Kameni spavač',
          'author': 'Mak Dizdar',
          'price': 21.0,
          'coverImageUrl': null,
          'isAvailable': true,
          'quantityInStock': 4,
          'quantitySold': 8,
        },
        {
          'id': 8,
          'title': 'Pobune',
          'author': 'Skender Kulenović',
          'price': 19.5,
          'coverImageUrl': null,
          'isAvailable': true,
          'quantityInStock': 7,
          'quantitySold': 3,
        },
      ];
      
      _books = booksData.map((data) => Book.fromJson(data)).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleBookAvailability(int bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final bookIndex = _books.indexWhere((book) => book.id == bookId);
      if (bookIndex >= 0) {
        final book = _books[bookIndex];
        
        final updatedBook = Book(
          id: book.id,
          title: book.title,
          author: book.author,
          price: book.price,
          coverImageUrl: book.coverImageUrl,
          isAvailable: !book.isAvailable,
        );
        
        _books[bookIndex] = updatedBook;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 