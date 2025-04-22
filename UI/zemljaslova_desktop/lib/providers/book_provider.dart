import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService;
  
  BookProvider(this._bookService);
  
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
      _books = await _bookService.fetchBooks();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Book?> getBookById(int id) async {
    try {
      return await _bookService.getBookById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
} 