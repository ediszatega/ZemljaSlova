import 'dart:async';
import 'package:flutter/material.dart';
import '../models/author.dart';
import '../services/author_service.dart';

class AuthorProvider with ChangeNotifier {
  final AuthorService _authorService;
  
  AuthorProvider(this._authorService);
  
  List<Author> _authors = [];
  bool _isLoading = false;
  String? _error;

  List<Author> get authors => [..._authors];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAuthors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authorService.fetchAuthors(
        page: 0,
        pageSize: 1000,
        sortBy: 'firstName',
        sortOrder: 'asc',
      );
      
      final List<Author> newAuthors = result['authors'] as List<Author>;
      _authors = newAuthors;
      
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