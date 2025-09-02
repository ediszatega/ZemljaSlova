import 'dart:typed_data';
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
    String? title,
    String? sortBy,
    String? sortOrder,
    Map<String, String>? filters,
    BookPurpose? bookPurpose,
  }) async {
    try {
      List<String> queryParams = ['IsAuthorIncluded=$isAuthorIncluded'];
      
      if (page != null) {
        queryParams.add('Page=$page');
      }
      
      if (pageSize != null) {
        queryParams.add('PageSize=$pageSize');
      }
      
      if (title != null && title.isNotEmpty) {
        queryParams.add('Title=${Uri.encodeComponent(title)}');
      }
      
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams.add('SortBy=${Uri.encodeComponent(sortBy)}');
      }
      
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams.add('SortOrder=${Uri.encodeComponent(sortOrder)}');
      }
      
      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value.isNotEmpty) {
            queryParams.add('${entry.key}=${Uri.encodeComponent(entry.value)}');
          }
        }
      }
      
      if (bookPurpose != null) {
        queryParams.add('BookPurpose=${bookPurpose.index + 1}');
      }
      
      final queryString = queryParams.join('&');
      final response = await _apiService.get('Book?$queryString');
            
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
      return {
        'books': <Book>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Book> getBookById(int id) async {
    try {
      final response = await _apiService.get('Book/$id?IsAuthorIncluded=true');
      return _mapBookFromBackend(response);
    } catch (e) {
      throw Exception('Knjiga nije pronađena');
    }
  }

  Future<Book> updateBook(
    int id,
    String title,
    String? description,
    double? price,
    String? dateOfPublish,
    int? edition,
    String? publisher,
    BookPurpose? bookPurpose,
    int numberOfPages,
    double? weight,
    String? dimensions,
    String? genre,
    String? binding,
    String? language,
    List<int> authorIds, {
    Uint8List? imageBytes,
  }) async {
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
        'bookPurpose': bookPurpose?.index != null ? (bookPurpose!.index + 1).toString() : null,
        'numberOfPages': numberOfPages,
        'weight': weight,
        'dimensions': dimensions,
        'genre': genre,
        'binding': binding,
        'language': language,
        'authorIds': authorIds.join(','),
      };
      
      dynamic response;
      if (imageBytes != null) {
        response = await _apiService.putMultipart('Book/$id/with-image', data, imageBytes: imageBytes, imageFieldName: 'image');
      } else {
        data['authorIds'] = authorIds;
        response = await _apiService.put('Book/$id', data);
      }
      return _mapBookFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom ažuriranja knjige');
    }
  }

  Future<Book> addBook(
    String title,
    String? description,
    double? price,
    String? dateOfPublish,
    int? edition,
    String? publisher,
    BookPurpose? bookPurpose,
    int numberOfPages,
    double? weight,
    String? dimensions,
    String? genre,
    String? binding,
    String? language,
    List<int> authorIds, {
    Uint8List? imageBytes,
  }) async {
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
        'bookPurpose': bookPurpose?.index != null ? (bookPurpose!.index + 1).toString() : null,
        'numberOfPages': numberOfPages,
        'weight': weight,
        'dimensions': dimensions,
        'genre': genre,
        'binding': binding,
        'language': language,
        'authorIds': authorIds.join(','),
      };
      
      dynamic response;
      if (imageBytes != null) {
        response = await _apiService.postMultipart('Book/with-image', data, imageBytes: imageBytes, imageFieldName: 'image');
      } else {
        data['authorIds'] = authorIds;
        response = await _apiService.post('Book', data);
      }
      return _mapBookFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom dodavanja knjige');
    }
  }

  Future<bool> deleteBook(int id) async {
    try {
      await _apiService.delete('Book/$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Book _mapBookFromBackend(dynamic bookData) {
    String? coverImageUrl;
    
    if (bookData['image'] != null) {
      final int bookId = bookData['id'] ?? 0;
      coverImageUrl = '${ApiService.baseUrl}/Book/$bookId/image';
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
    BookPurpose? bookPurpose;
    if (bookData['bookPurpose'] != null) {
      final purposeValue = bookData['bookPurpose'] as int;
      bookPurpose = BookPurpose.values.firstWhere(
        (p) => p.index + 1 == purposeValue,
        orElse: () => BookPurpose.sell,
      );
    }
    int numberOfPages = bookData['numberOfPages'] ?? 0;
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
      bookPurpose: bookPurpose,
      numberOfPages: numberOfPages,
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