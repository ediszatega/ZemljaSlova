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
        _authors.add(newAuthor);
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
} 