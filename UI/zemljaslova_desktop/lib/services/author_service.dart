import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/author.dart';
import 'api_service.dart';

class AuthorService {
  final ApiService _apiService;
  
  AuthorService(this._apiService);
  
  Future<List<Author>> fetchAuthors() async {
    try {
      final response = await _apiService.get('Author');
      
      debugPrint('API response: $response');
      
      if (response != null) {
        final authorsList = response['resultList'] as List;
        
        return authorsList
            .map((authorJson) => _mapAuthorFromBackend(authorJson))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to fetch authors: $e');
      return [];
    }
  }
  
  Future<Author> getAuthorById(int id) async {
    try {
      final response = await _apiService.get('Author/$id');
      
      if (response != null) {
        return _mapAuthorFromBackend(response);
      }
      
      throw Exception('Author not found');
    } catch (e) {
      debugPrint('Failed to get author: $e');
      throw Exception('Failed to get author: $e');
    }
  }

  Author _mapAuthorFromBackend(dynamic authorData) {
    String? dateOfBirth;
    if (authorData['dateOfBirth'] != null) {
      final date = DateTime.parse(authorData['dateOfBirth']);
      dateOfBirth = '${date.day}.${date.month}.${date.year}';
    }

    return Author(
      id: authorData['id'] ?? 0,
      firstName: authorData['firstName'] ?? '',
      lastName: authorData['lastName'] ?? '',
      dateOfBirth: dateOfBirth,
      genre: authorData['genre'],
      biography: authorData['biography'],
    );
  }
} 