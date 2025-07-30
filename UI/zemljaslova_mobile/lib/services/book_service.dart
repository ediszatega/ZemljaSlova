import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/author.dart';
import 'api_service.dart';

class BookService {
  final ApiService _apiService;
  
  BookService(this._apiService);
  
  Future<Map<String, dynamic>> fetchBooks({
    bool isAuthorIncluded = true,
    int? page,
    int? pageSize,
    String? name,
    String? sortBy,
    String? sortOrder,
    Map<String, String>? filters,
  }) async {
    try {
      List<String> queryParams = ['IsAuthorIncluded=$isAuthorIncluded'];
      
      if (page != null) {
        queryParams.add('Page=$page');
      }
      
      if (pageSize != null) {
        queryParams.add('PageSize=$pageSize');
      }
      
      if (name != null && name.isNotEmpty) {
        queryParams.add('Title=${Uri.encodeComponent(name)}');
      }
      
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams.add('SortBy=${Uri.encodeComponent(sortBy)}');
      }
      
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams.add('SortOrder=${Uri.encodeComponent(sortOrder)}');
      }
      
      if (filters != null) {
        for (final entry in filters.entries) {
          queryParams.add('${entry.key}=${Uri.encodeComponent(entry.value)}');
        }
      }
      
      final queryString = queryParams.join('&');
      final response = await _apiService.get('Book?$queryString');
      
      debugPrint('API response: $response');
      
      if (response != null) {
        final booksList = response['resultList'] as List;
        final totalCount = response['count'] as int;
        
        final books = booksList
            .map((bookJson) => _mapBookFromBackend(bookJson))
            .toList();
            
        return {
          'books': books,
          'totalCount': totalCount,
        };
      }
      
      return {
        'books': <Book>[],
        'totalCount': 0,
      };
    } catch (e) {
      debugPrint('Failed to fetch books: $e');
      return {
        'books': <Book>[],
        'totalCount': 0,
      };
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