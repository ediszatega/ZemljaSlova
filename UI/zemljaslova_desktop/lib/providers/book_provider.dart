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

  Future<void> fetchBooks({bool isAuthorIncluded = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _bookService.fetchBooks(isAuthorIncluded: isAuthorIncluded);
      
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

  Future<bool> updateBook(
    int id,
    String title,
    String? description,
    double price,
    String? dateOfPublish,
    int? edition,
    String? publisher,
    String? bookPurpos,
    int numberOfPages,
    double? weight,
    String? dimensions,
    String? genre,
    String? binding,
    String? language,
    List<int> authorIds,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedBook = await _bookService.updateBook(
        id,
        title,
        description,
        price,
        dateOfPublish,
        edition,
        publisher,
        bookPurpos,
        numberOfPages,
        weight,
        dimensions,
        genre,
        binding,
        language,
        authorIds,
      );
      
      if (updatedBook != null) {
        final index = _books.indexWhere((book) => book.id == id);
        if (index >= 0) {
          _books[index] = updatedBook;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Failed to update book";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addBook(
    String title,
    String? description,
    double price,
    String? dateOfPublish,
    int? edition,
    String? publisher,
    String bookPurpos,
    int numberOfPages,
    double? weight,
    String? dimensions,
    String? genre,
    String? binding,
    String? language,
    List<int> authorIds,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newBook = await _bookService.addBook(
        title,
        description,
        price,
        dateOfPublish,
        edition,
        publisher,
        bookPurpos,
        numberOfPages,
        weight,
        dimensions,
        genre,
        binding,
        language,
        authorIds,
      );
      
      if (newBook != null) {
        _books.add(newBook);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Failed to add book";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _bookService.deleteBook(id);
      
      if (success) {
        _books.removeWhere((book) => book.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Failed to delete book";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 