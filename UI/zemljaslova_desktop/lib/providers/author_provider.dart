import 'package:flutter/material.dart';
import '../models/author.dart';
import '../services/author_service.dart';
import '../widgets/paginated_data_widget.dart';

class AuthorProvider with ChangeNotifier implements PaginatedDataProvider<Author> {
  final AuthorService _authorService;
  List<Author> _authors = [];
  bool _isLoading = false;
  String? _error;
  
  // Pagination state
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  bool _hasMoreData = true;

  AuthorProvider(this._authorService);

  List<Author> get authors => [..._authors];
  
  // PaginatedDataProvider interface implementation
  @override
  List<Author> get items => authors;
  
  bool get isLoading => _isLoading;
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

  Future<void> fetchAuthors({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _authors.clear();
      _hasMoreData = true;
      _error = null;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authorService.fetchAuthors(
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      final List<Author> newAuthors = result['authors'] as List<Author>;
      _totalCount = result['totalCount'] as int;
      
      if (refresh || _authors.isEmpty) {
        _authors = newAuthors;
      } else {
        _authors.addAll(newAuthors);
      }
      
      _hasMoreData = _authors.length < _totalCount;
      
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
      final newAuthor = await _authorService.addAuthor(
        firstName,
        lastName,
        dateOfBirth,
        genre,
        biography,
      );
      
      if (newAuthor != null) {
        // Refresh to get updated pagination
        await refresh();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Failed to add author";
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
      final updatedAuthor = await _authorService.updateAuthor(
        id,
        firstName,
        lastName,
        dateOfBirth,
        genre,
        biography,
      );
      
      if (updatedAuthor != null) {
        final index = _authors.indexWhere((author) => author.id == id);
        if (index >= 0) {
          _authors[index] = updatedAuthor;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Failed to update author";
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

  Future<bool> deleteAuthor(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authorService.deleteAuthor(id);
      
      if (success) {
        // Refresh to get updated pagination
        await refresh();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Failed to delete author";
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