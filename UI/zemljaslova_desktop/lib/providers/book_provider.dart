import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../widgets/paginated_data_widget.dart';

class BookProvider with ChangeNotifier implements PaginatedDataProvider<Book> {
  final BookService _bookService;
  
  BookProvider(this._bookService);
  
  List<Book> _books = [];
  bool _isLoading = false;
  String? _error;
  
  // Pagination state
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  bool _hasMoreData = true;

  List<Book> get books => [..._books];
  
  // PaginatedDataProvider interface implementation
  @override
  List<Book> get items => books;
  
  bool get isLoading => _isLoading;
  @override
  bool get isInitialLoading => _isLoading && _books.isEmpty;
  @override
  bool get isLoadingMore => _isLoading && _books.isNotEmpty;
  @override
  String? get error => _error;
  int get currentPage => _currentPage;
  @override
  int get pageSize => _pageSize;
  @override
  int get totalCount => _totalCount;
  @override
  bool get hasMoreData => _hasMoreData;
  int get totalPages => (_totalCount / _pageSize).ceil();

  Future<void> fetchBooks({bool isAuthorIncluded = true, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _books.clear();
      _hasMoreData = true;
      _error = null;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _bookService.fetchBooks(
        isAuthorIncluded: isAuthorIncluded,
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      final List<Book> newBooks = result['books'] as List<Book>;
      _totalCount = result['totalCount'] as int;
      
      if (refresh || _books.isEmpty) {
        _books = newBooks;
      } else {
        _books.addAll(newBooks);
      }
      
      _hasMoreData = _books.length < _totalCount;
      
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  @override
  Future<void> loadMore({bool isAuthorIncluded = true}) async {
    if (_isLoading || !_hasMoreData) return;
    
    _currentPage++;
    await fetchBooks(isAuthorIncluded: isAuthorIncluded, refresh: false);
  }
  
  @override
  Future<void> refresh({bool isAuthorIncluded = true}) async {
    await fetchBooks(isAuthorIncluded: isAuthorIncluded, refresh: true);
  }
  
  @override
  void setPageSize(int newPageSize) {
    if (newPageSize != _pageSize) {
      _pageSize = newPageSize;
      refresh();
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
        // Refresh to get updated pagination
        await refresh();
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
        // Refresh to get updated pagination
        await refresh();
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