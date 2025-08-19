import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/ticket_type.dart';
import 'api_service.dart';

class EventService {
  final ApiService _apiService;
  
  EventService(this._apiService);
  
  Future<Map<String, dynamic>> fetchEvents({
    bool isTicketTypeIncluded = true,
    int? page,
    int? pageSize,
    String? name,
    String? sortBy,
    String? sortOrder,
    Map<String, String>? filters,
  }) async {
    try {
      List<String> queryParams = ['IsTicketTypeIncluded=$isTicketTypeIncluded'];
      
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
      
      // Add filters
      if (filters != null) {
        for (final entry in filters.entries) {
          queryParams.add('${entry.key}=${Uri.encodeComponent(entry.value)}');
        }
      }
      
      final queryString = queryParams.join('&');
      final response = await _apiService.get('Event?$queryString');
      
      debugPrint('API response: $response');
      
      if (response != null) {
        final eventsList = response['resultList'] as List;
        final totalCount = response['count'] as int;
        
        final events = eventsList
            .map((eventJson) => _mapEventFromBackend(eventJson))
            .toList();
            
        return {
          'events': events,
          'totalCount': totalCount,
        };
      }
      
      return {
        'events': <Event>[],
        'totalCount': 0,
      };
    } catch (e) {
      debugPrint('Failed to fetch events: $e');
      return {
        'events': <Event>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Event> getEventById(int id) async {
    try {
      final response = await _apiService.get('Event/GetEventWithTicketTypes/$id');
      
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
    
    // Parse ticket types
    List<TicketType>? ticketTypes;
    
    if (eventData.containsKey('ticketTypes') && eventData['ticketTypes'] != null) {
      final typesList = eventData['ticketTypes'] as List;
      
      if (typesList.isNotEmpty) {
        ticketTypes = typesList.map((ticketTypeJson) {
          var id = ticketTypeJson['id'];
          var eventId = ticketTypeJson['eventId'];
          var price = ticketTypeJson['price'];
          var name = ticketTypeJson['name'];
          var description = ticketTypeJson['description'];
          var initialQuantity = ticketTypeJson['initialQuantity'];
          var currentQuantity = ticketTypeJson['currentQuantity'];
          
          return TicketType(
            id: id,
            eventId: eventId,
            price: (price as num).toDouble(),
            name: name,
            description: description,
            initialQuantity: initialQuantity,
            currentQuantity: currentQuantity,
          );
        }).toList();
      }
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