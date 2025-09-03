import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../models/author.dart';
import 'api_service.dart';

class AuthorService {
  final ApiService _apiService;
  
  AuthorService(this._apiService);
  
  Future<Map<String, dynamic>> fetchAuthors({
    int? page,
    int? pageSize,
    String? name,
    String? sortBy,
    String? sortOrder,
    Map<String, String>? filters,
  }) async {
    try {
      List<String> queryParams = [];
      
      if (page != null) {
        queryParams.add('Page=$page');
      }
      
      if (pageSize != null) {
        queryParams.add('PageSize=$pageSize');
      }
      
      if (name != null && name.isNotEmpty) {
        queryParams.add('Name=${Uri.encodeComponent(name)}');
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
      
      final queryString = queryParams.join('&');
      final response = await _apiService.get('Author?$queryString');
      
      if (response != null) {
        final authorsList = response['resultList'] as List;
        final totalCount = response['count'] as int;
        
        final authors = authorsList
            .map((authorJson) => _mapAuthorFromBackend(authorJson))
            .toList();
            
        return {
          'authors': authors,
          'totalCount': totalCount,
        };
      }
      
      return {
        'authors': <Author>[],
        'totalCount': 0,
      };
    } catch (e) {
      return {
        'authors': <Author>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Author> getAuthorById(int id) async {
    try {
      final response = await _apiService.get('Author/$id');
      return _mapAuthorFromBackend(response);
    } catch (e) {
      throw Exception('Autor nije pronađen');
    }
  }
  
  Future<Author> addAuthor(
    String firstName,
    String lastName,
    String? dateOfBirth,
    String? genre,
    String? biography, {
    Uint8List? imageBytes,
  }) async {
    try {
      // Convert date string to datetime format if provided
      DateTime? birthDate;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        final parts = dateOfBirth.split('.');
        if (parts.length == 3) {
          birthDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      }
      
      final Map<String, dynamic> data = {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': birthDate?.toIso8601String(),
        'genre': genre,
        'biography': biography,
      };
      
      dynamic response;
      if (imageBytes != null) {
        response = await _apiService.postMultipart('Author/with-image', data, imageBytes: imageBytes, imageFieldName: 'image');
      } else {
        response = await _apiService.post('Author', data);
      }
      return _mapAuthorFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom dodavanja autora');
    }
  }

  Future<Author> updateAuthor(
    int id,
    String firstName,
    String lastName,
    String? dateOfBirth,
    String? genre,
    String? biography, {
    Uint8List? imageBytes,
  }) async {
    try {
      // Convert date string to datetime format if provided
      DateTime? birthDate;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        final parts = dateOfBirth.split('.');
        if (parts.length == 3) {
          birthDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      }
      
      final Map<String, dynamic> data = {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': birthDate?.toIso8601String(),
        'genre': genre,
        'biography': biography,
      };
      
      dynamic response;
      if (imageBytes != null) {
        response = await _apiService.putMultipart('Author/$id/with-image', data, imageBytes: imageBytes, imageFieldName: 'image');
      } else {
        response = await _apiService.put('Author/$id', data);
      }
      return _mapAuthorFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom ažuriranja autora');
    }
  }

  Future<bool> deleteAuthor(int id) async {
    try {
      await _apiService.delete('Author/$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  String? getAuthorImageUrl(int id) {
    return '${ApiService.baseUrl}/Author/$id/image';
  }

  Author _mapAuthorFromBackend(dynamic authorData) {
    String? dateOfBirth;
    if (authorData['dateOfBirth'] != null) {
      final date = DateTime.parse(authorData['dateOfBirth']);
      dateOfBirth = '${date.day}.${date.month}.${date.year}';
    }

    String? imageUrl;
    if (authorData['image'] != null) {
      final int authorId = authorData['id'] ?? 0;
      imageUrl = '${ApiService.baseUrl}/Author/$authorId/image';
    }

    return Author(
      id: authorData['id'] ?? 0,
      firstName: authorData['firstName'] ?? '',
      lastName: authorData['lastName'] ?? '',
      dateOfBirth: dateOfBirth,
      genre: authorData['genre'],
      biography: authorData['biography'],
      imageUrl: imageUrl,
    );
  }
} 