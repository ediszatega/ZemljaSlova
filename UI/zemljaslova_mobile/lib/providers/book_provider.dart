import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/book_filters.dart';
import '../services/book_service.dart';
import '../widgets/paginated_data_widget.dart';

class BookProvider with ChangeNotifier implements PaginatedDataProvider<Book> {
  final BookService _bookService;
  
  BookProvider(this._bookService);
  
  List<Book> _books = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  bool _hasMoreData = true;
  
  String _searchQuery = '';
  Timer? _searchDebounceTimer;
  
  // Sorting state
  String _sortBy = 'title';
  String _sortOrder = 'asc';
  
  // Filters state
  BookFilters _filters = const BookFilters();
  
  // Current book purpose - this is the key to reliable filtering
  BookPurpose? _currentBookPurpose;

  List<Book> get books => [..._books];
  
  @override
  List<Book> get items => books;
  
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
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
  
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  BookFilters get filters => _filters;
  BookPurpose? get currentBookPurpose => _currentBookPurpose;

  // Initialize the provider for a specific book purpose
  void initializeForBookPurpose(BookPurpose bookPurpose) {
    if (_currentBookPurpose != bookPurpose) {
      _currentBookPurpose = bookPurpose;
      // Clear existing data when switching purposes
      _books.clear();
      _currentPage = 0;
      _hasMoreData = true;
      _error = null;
      clearSearch();
      clearFilters();
      notifyListeners();
    }
  }

  // Clear the book purpose and reset state
  void clearBookPurpose() {
    _currentBookPurpose = null;
    _books.clear();
    _currentPage = 0;
    _hasMoreData = true;
    _error = null;
    clearSearch();
    clearFilters();
    notifyListeners();
  }

  Future<void> fetchBooks({bool isAuthorIncluded = true, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      if (_books.isEmpty) {
        _books.clear();
      }
      _hasMoreData = true;
      _error = null;
    }
    
    if (_books.isNotEmpty && refresh) {
      _isUpdating = true;
    } else {
      _isLoading = true;
    }
    notifyListeners();

    try {
      final result = await _bookService.fetchBooks(
        isAuthorIncluded: isAuthorIncluded,
        page: _currentPage,
        pageSize: _pageSize,
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        filters: _filters.hasActiveFilters ? _filters.toQueryParams() : null,
        bookPurpose: _currentBookPurpose, // Always use the current book purpose
      );
      
      final List<Book> newBooks = result['books'] as List<Book>;
      _totalCount = result['totalCount'] as int;
      
      if (refresh) {
        _books = newBooks;
      } else {
        _books.addAll(newBooks);
      }
      
      _hasMoreData = _books.length < _totalCount;
      
      _isLoading = false;
      _isUpdating = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isUpdating = false;
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
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    
    _searchDebounceTimer?.cancel();
    
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      refresh();
    });
  }
  
  void setSorting(String sortBy, String sortOrder) {
    if (_sortBy != sortBy || _sortOrder != sortOrder) {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
      refresh();
    }
  }
  
  void clearSearch() {
    _searchQuery = '';
    _searchDebounceTimer?.cancel();
    _books.clear();
    refresh();
  }
  
  void setFilters(BookFilters filters) {
    _filters = filters;
    _books.clear();
    refresh();
  }
  
  void clearFilters() {
    _filters = const BookFilters();
    _books.clear();
    refresh();
  }
  
  String get searchQuery => _searchQuery;
  
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