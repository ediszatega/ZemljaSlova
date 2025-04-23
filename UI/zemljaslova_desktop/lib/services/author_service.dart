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
  
  Future<Author?> addAuthor(
    String firstName,
    String lastName,
    String? dateOfBirth,
    String? genre,
    String? biography,
  ) async {
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
      
      final response = await _apiService.post('Author', data);
      
      if (response != null) {
        return _mapAuthorFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to add author: $e');
      return null;
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