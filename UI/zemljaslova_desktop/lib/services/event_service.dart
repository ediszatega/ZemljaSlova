import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/ticket_type.dart';
import 'api_service.dart';

class EventService {
  final ApiService _apiService;
  
  EventService(this._apiService);
  
  Future<List<Event>> fetchEvents() async {
    try {
      final response = await _apiService.get('Event?IsTicketTypeIncluded=true');
      
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
      final response = await _apiService.get('Event/$id?IsTicketTypeIncluded=true');
      
      if (response != null) {
        return _mapEventFromBackend(response);
      }
      
      throw Exception('Event not found');
    } catch (e) {
      debugPrint('Failed to get event: $e');
      throw Exception('Failed to get event: $e');
    }
  }

  // Add a new event to the system
  Future<Event?> addEvent({
    required String title,
    required String description,
    String? location,
    required DateTime startAt,
    required DateTime endAt,
    String? organizer,
    String? lecturers,
    List<int>? coverImage, // For image bytes
    int? maxNumberOfPeople,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'title': title,
        'description': description,
        'location': location,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'organizer': organizer,
        'lecturers': lecturers,
        'coverImage': coverImage,
        'maxNumberOfPeople': maxNumberOfPeople,
      };
      
      final response = await _apiService.post('Event', data);
      
      if (response != null) {
        return _mapEventFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to add event: $e');
      return null;
    }
  }
  
  // Add a ticket type for an event
  Future<TicketType?> addTicketType({
    required int eventId,
    required double price,
    required String name,
    String? description,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'eventId': eventId,
        'price': price,
        'name': name,
        'description': description,
      };
      
      final response = await _apiService.post('TicketType', data);
      
      if (response != null) {
        return TicketType(
          id: response['id'],
          eventId: response['eventId'],
          price: (response['price'] as num).toDouble(),
          name: response['name'],
          description: response['description'],
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to add ticket type: $e');
      return null;
    }
  }
  
  // Get ticket types for an event
  Future<List<TicketType>> getTicketTypesForEvent(int eventId) async {
    try {
      final response = await _apiService.get('TicketType?EventId=$eventId');
      
      if (response != null && response['resultList'] != null) {
        final ticketTypesList = response['resultList'] as List;
        
        return ticketTypesList.map((item) => TicketType(
          id: item['id'],
          eventId: item['eventId'],
          price: (item['price'] as num).toDouble(),
          name: item['name'],
          description: item['description'],
        )).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get ticket types: $e');
      return [];
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
    
    // Parse ticket types if available
    List<TicketType>? ticketTypes;
    if (eventData['ticketTypes'] != null) {
      ticketTypes = (eventData['ticketTypes'] as List)
          .map((ticketTypeJson) => TicketType(
                id: ticketTypeJson['id'],
                eventId: ticketTypeJson['eventId'],
                price: (ticketTypeJson['price'] as num).toDouble(),
                name: ticketTypeJson['name'],
                description: ticketTypeJson['description'],
              ))
          .toList();
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
      ticketTypes: ticketTypes,
    );
  }
} 