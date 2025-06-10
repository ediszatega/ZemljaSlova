import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/author.dart';
import 'api_service.dart';

class BookService {
  final ApiService _apiService;
  
  BookService(this._apiService);
  
  Future<List<Book>> fetchBooks({bool isAuthorIncluded = true}) async {
    try {
      final response = await _apiService.get('Book?IsAuthorIncluded=$isAuthorIncluded');
      
      debugPrint('API response: $response');
      
      if (response != null) {
        final booksList = response['resultList'] as List;
        
        return booksList
            .map((bookJson) => _mapBookFromBackend(bookJson))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to fetch books: $e');
      return [];
    }
  }
  
  Future<Book> getBookById(int id) async {
    try {
      final response = await _apiService.get('Book/$id?IsAuthorIncluded=true');
      
      if (response != null) {
        return _mapBookFromBackend(response);
      }
      
      throw Exception('Book not found');
    } catch (e) {
      debugPrint('Failed to get book: $e');
      throw Exception('Failed to get book: $e');
    }
  }

  Book _mapBookFromBackend(dynamic bookData) {
    String? coverImageUrl;
    if (bookData['image'] != null) {
      if (bookData['image'] is List) {
        final bytes = List<int>.from(bookData['image']);
        coverImageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else if (bookData['image'] is String) {
        coverImageUrl = bookData['image'];
      }
    }

    bool isAvailable = bookData['isAvailable'] ?? false;
    int quantityInStock = bookData['quantityInStock'] ?? bookData['numberInStock'] ?? 0;
    
    String? description = bookData['description'];
    String? dateOfPublish;
    if (bookData['dateOfPublish'] != null) {
      final date = DateTime.parse(bookData['dateOfPublish']);
      dateOfPublish = '${date.day}.${date.month}.${date.year}';
    }
    int? edition = bookData['edition'];
    String? publisher = bookData['publisher'];
    String? bookPurpos = bookData['bookPurpos'];
    int? numberOfPages = bookData['numberOfPages'];
    double? weight = bookData['weight']?.toDouble();
    String? dimensions = bookData['dimensions'];
    String? genre = bookData['genre'];
    String? binding = bookData['binding'];
    String? language = bookData['language'];
    
    List<Author> authors = [];
    List<int> authorIds = [];
    
    if (bookData['authors'] != null && bookData['authors'] is List && (bookData['authors'] as List).isNotEmpty) {
      List<dynamic> authorsList = bookData['authors'];
      authors = authorsList.map((authorData) => Author(
        id: authorData['id'] ?? 0,
        firstName: authorData['firstName'] ?? '',
        lastName: authorData['lastName'] ?? '',
        dateOfBirth: authorData['dateOfBirth'] != null 
            ? DateTime.parse(authorData['dateOfBirth']).toString()
            : null,
        genre: authorData['genre'],
        biography: authorData['biography'],
      )).toList();
      
      authorIds = authors.map((author) => author.id).toList();
    }

    return Book(
      id: bookData['id'] ?? 0,
      title: bookData['title'] ?? '',
      price: (bookData['price'] ?? 0).toDouble(),
      coverImageUrl: coverImageUrl,
      isAvailable: isAvailable,
      quantityInStock: quantityInStock,
      quantitySold: bookData['quantitySold'] ?? 0,
      description: description,
      dateOfPublish: dateOfPublish,
      edition: edition,
      publisher: publisher,
      bookPurpos: bookPurpos,
      numberOfPages: numberOfPages ?? 0,
      weight: weight,
      dimensions: dimensions,
      genre: genre,
      binding: binding,
      language: language,
      authorIds: authorIds,
      authors: authors.isNotEmpty ? authors : null,
    );
  }
} 