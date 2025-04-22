import 'package:flutter/material.dart';
import '../models/author.dart';
import '../services/author_service.dart';

class AuthorProvider with ChangeNotifier {
  final AuthorService _authorService;
  List<Author> _authors = [];
  bool _isLoading = false;
  String? _error;

  AuthorProvider(this._authorService);

  List<Author> get authors => [..._authors];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAuthors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedAuthors = await _authorService.fetchAuthors();
      _authors = fetchedAuthors;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
} 