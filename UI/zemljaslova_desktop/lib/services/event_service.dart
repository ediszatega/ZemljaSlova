import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/event.dart';
import 'api_service.dart';

class EventService {
  final ApiService _apiService;
  
  EventService(this._apiService);
  
  Future<List<Event>> fetchEvents() async {
    try {
      final response = await _apiService.get('Event');
      
      debugPrint('API response: $response');
      
      if (response != null) {
        final eventsList = response['resultList'] as List;
        
        return eventsList
            .map((eventJson) => _mapEventFromBackend(eventJson))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to fetch events: $e');
      return [];
    }
  }
  
  Future<Event> getEventById(int id) async {
    try {
      final response = await _apiService.get('Event/$id');
      
      if (response != null) {
        return _mapEventFromBackend(response);
      }
      
      throw Exception('Event not found');
    } catch (e) {
      debugPrint('Failed to get event: $e');
      throw Exception('Failed to get event: $e');
    }
  }

  Event _mapEventFromBackend(dynamic eventData) {
    String? coverImageUrl;
    if (eventData['coverImage'] != null) {
      if (eventData['coverImage'] is List) {
        final bytes = List<int>.from(eventData['coverImage']);
        coverImageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else if (eventData['coverImage'] is String) {
        coverImageUrl = eventData['coverImage'];
      }
    }

    // Parse dates
    DateTime startAt = DateTime.now();
    if (eventData['startAt'] != null) {
      startAt = DateTime.parse(eventData['startAt']);
    }
    
    DateTime endAt = DateTime.now();
    if (eventData['endAt'] != null) {
      endAt = DateTime.parse(eventData['endAt']);
    }

    return Event(
      id: eventData['id'] ?? 0,
      title: eventData['title'] ?? '',
      description: eventData['description'] ?? '',
      location: eventData['location'],
      startAt: startAt,
      endAt: endAt,
      organizer: eventData['organizer'],
      lecturers: eventData['lecturers'],
      coverImageUrl: coverImageUrl,
      maxNumberOfPeople: eventData['maxNumberOfPeople'],
    );
  }
} 