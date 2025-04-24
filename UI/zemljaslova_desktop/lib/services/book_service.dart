import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import 'api_service.dart';

class BookService {
  final ApiService _apiService;
  
  BookService(this._apiService);
  
  Future<List<Book>> fetchBooks() async {
    try {
      final response = await _apiService.get('Book');
      
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
      final response = await _apiService.get('Book/$id');
      
      if (response != null) {
        return _mapBookFromBackend(response);
      }
      
      throw Exception('Book not found');
    } catch (e) {
      debugPrint('Failed to get book: $e');
      throw Exception('Failed to get book: $e');
    }
  }

  Future<Book?> updateBook(
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
    int? authorId,
  ) async {
    try {
      // Convert date string to datetime format if provided
      DateTime? publishDate;
      if (dateOfPublish != null && dateOfPublish.isNotEmpty) {
        final parts = dateOfPublish.split('.');
        if (parts.length == 3) {
          publishDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      }
      
      final Map<String, dynamic> data = {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'dateOfPublish': publishDate?.toIso8601String(),
        'edition': edition,
        'publisher': publisher,
        'bookPurpos': bookPurpos,
        'numberOfPages': numberOfPages,
        'weight': weight,
        'dimensions': dimensions,
        'genre': genre,
        'binding': binding,
        'language': language,
        'authorId': authorId,
      };
      
      final response = await _apiService.put('Book/$id', data);
      
      if (response != null) {
        return _mapBookFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to update book: $e');
      return null;
    }
  }

  Future<Book?> addBook(
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
    int? authorId,
  ) async {
    try {
      // Convert date string to datetime format if provided
      DateTime? publishDate;
      if (dateOfPublish != null && dateOfPublish.isNotEmpty) {
        final parts = dateOfPublish.split('.');
        if (parts.length == 3) {
          publishDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      }
      
      final Map<String, dynamic> data = {
        'title': title,
        'description': description,
        'price': price,
        'dateOfPublish': publishDate?.toIso8601String(),
        'edition': edition,
        'publisher': publisher,
        'bookPurpos': bookPurpos,
        'numberOfPages': numberOfPages,
        'weight': weight,
        'dimensions': dimensions,
        'genre': genre,
        'binding': binding,
        'language': language,
        'authorId': authorId,
      };
      
      final response = await _apiService.post('Book', data);
      
      if (response != null) {
        return _mapBookFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to add book: $e');
      return null;
    }
  }

  Book _mapBookFromBackend(dynamic bookData) {
    String? coverImageUrl;
    if (bookData['coverImage'] != null) {
      if (bookData['coverImage'] is List) {
        final bytes = List<int>.from(bookData['coverImage']);
        coverImageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else if (bookData['coverImage'] is String) {
        coverImageUrl = bookData['coverImage'];
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
    int? authorId = bookData['authorId'];
    
    String? authorFirstName;
    String? authorLastName;
    String? authorFullName;
    
    if (bookData['author'] is Map) {
      Map<String, dynamic> authorData = bookData['author'];
      authorFirstName = authorData['firstName'];
      authorLastName = authorData['lastName'];
      authorFullName = '${authorFirstName ?? ''} ${authorLastName ?? ''}'.trim();
    } else {
      authorFullName = "Autor nepoznat";
    }


    return Book(
      id: bookData['id'] ?? 0,
      title: bookData['title'] ?? '',
      author: authorFullName,
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
      authorId: authorId,
      authorFirstName: authorFirstName,
      authorLastName: authorLastName,
    );
  }
} 