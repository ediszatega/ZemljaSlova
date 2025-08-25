import 'dart:async';
import 'package:flutter/material.dart';
import '../models/author.dart';
import '../models/author_filters.dart';
import '../services/author_service.dart';
import '../widgets/paginated_data_widget.dart';

class AuthorProvider with ChangeNotifier implements PaginatedDataProvider<Author> {
  final AuthorService _authorService;
  List<Author> _authors = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  
  // Pagination state
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  bool _hasMoreData = true;
  
  // Search state
  String _searchQuery = '';
  Timer? _searchDebounceTimer;
  
  // Sorting state
  String _sortBy = 'name';
  String _sortOrder = 'asc';
  
  // Filter state
  AuthorFilters _filters = AuthorFilters.empty;

  AuthorProvider(this._authorService);

  List<Author> get authors => [..._authors];
  
  // PaginatedDataProvider interface implementation
  @override
  List<Author> get items => authors;
  
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  @override
  bool get isInitialLoading => _isLoading && _authors.isEmpty;
  @override
  bool get isLoadingMore => _isLoading && _authors.isNotEmpty;
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
  AuthorFilters get filters => _filters;

  Future<void> fetchAuthors({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      if (_authors.isEmpty) {
        _authors.clear();
      }
      _hasMoreData = true;
      _error = null;
    }
    
    if (_authors.isNotEmpty && refresh) {
      _isUpdating = true;
    } else {
      _isLoading = true;
    }
    notifyListeners();

    try {
      final result = await _authorService.fetchAuthors(
        page: _currentPage,
        pageSize: _pageSize,
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        filters: _filters.hasActiveFilters ? _filters.toQueryParams() : null,
      );
      
      final List<Author> newAuthors = result['authors'] as List<Author>;
      _totalCount = result['totalCount'] as int;
      
      if (refresh) {
        _authors = newAuthors;
      } else {
        _authors.addAll(newAuthors);
      }
      
      _hasMoreData = _authors.length < _totalCount;
      
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
  Future<void> loadMore() async {
    if (_isLoading || !_hasMoreData) return;
    
    _currentPage++;
    await fetchAuthors(refresh: false);
  }
  
  @override
  Future<void> refresh() async {
    await fetchAuthors(refresh: true);
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
  
  void setFilters(AuthorFilters filters) {
    if (_filters != filters) {
      _filters = filters;
      refresh();
    }
  }
  
  void clearFilters() {
    _filters = AuthorFilters.empty;
    refresh();
  }
  
  void clearSearch() {
    _searchQuery = '';
    _searchDebounceTimer?.cancel();
    _authors.clear();
    refresh();
  }
  
  String get searchQuery => _searchQuery;

  Future<Author?> getAuthorById(int id) async {
    try {
      return await _authorService.getAuthorById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  Future<bool> addAuthor(
    String firstName,
    String lastName,
    String? dateOfBirth,
    String? genre,
    String? biography,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authorService.addAuthor(
        firstName,
        lastName,
        dateOfBirth,
        genre,
        biography,
      );
      
      // Refresh to get updated pagination
      await refresh();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAuthor(
    int id,
    String firstName,
    String lastName,
    String? dateOfBirth,
    String? genre,
    String? biography,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authorService.updateAuthor(
        id,
        firstName,
        lastName,
        dateOfBirth,
        genre,
        biography,
      );
      
      await refresh();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAuthor(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authorService.deleteAuthor(id);
      
      await refresh();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 