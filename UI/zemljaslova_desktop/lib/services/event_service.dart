import 'dart:typed_data';
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
      
      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value.isNotEmpty) {
            queryParams.add('${entry.key}=${Uri.encodeComponent(entry.value)}');
          }
        }
      }
      
      final queryString = queryParams.join('&');
      final response = await _apiService.get('Event?$queryString');
      
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
      return {
        'events': <Event>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Event> getEventById(int id) async {
    try {
      final response = await _apiService.get('Event/GetEventWithTicketTypes/${id}');      
        return _mapEventFromBackend(response);
    } catch (e) {
      throw Exception('Događaj nije pronađen.');
    }
  }

  Future<Event?> addEvent({
    required String title,
    required String description,
    String? location,
    required DateTime startAt,
    required DateTime endAt,
    String? organizer,
    String? lecturers,
    int? maxNumberOfPeople,
    Uint8List? imageBytes,
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
        'maxNumberOfPeople': maxNumberOfPeople,
      };
      
      final response = imageBytes != null
          ? await _apiService.postMultipart('Event/with-image', data,
              imageBytes: imageBytes, imageFieldName: 'image')
          : await _apiService.post('Event', data);
        return _mapEventFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom dodavanja događaja.');
    }
  }
  
  Future<Event?> updateEvent({
    required int id,
    required String title,
    required String description,
    String? location,
    required DateTime startAt,
    required DateTime endAt,
    String? organizer,
    String? lecturers,
    int? maxNumberOfPeople,
    Uint8List? imageBytes,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'organizer': organizer,
        'lecturers': lecturers,
        'maxNumberOfPeople': maxNumberOfPeople,
      };
      
      final response = imageBytes != null
          ? await _apiService.putMultipart('Event/$id/with-image', data,
              imageBytes: imageBytes, imageFieldName: 'image')
          : await _apiService.put('Event/$id', data);
      
      return _mapEventFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom ažuriranja događaja.');
    }
  }
  
  // Add a ticket type for an event
  Future<TicketType?> addTicketType({
    required int eventId,
    required double price,
    required String name,
    String? description,
    int? initialQuantity,
    int? userId,
  }) async {
    try {
      final data = {
        'eventId': eventId,
        'price': price,
        'name': name,
        'description': description ?? '',
        'initialQuantity': initialQuantity,
        'userId': userId,
      };
      
      final response = await _apiService.post('TicketType', data);

        final ticketType = TicketType(
          id: response['id'],
          name: response['name'],
          price: (response['price'] as num).toDouble(),
          description: response['description'] ?? '',
          eventId: response['eventId'],
          initialQuantity: response['initialQuantity'],
          currentQuantity: response['currentQuantity'],
        );
        return ticketType;
    } catch (e) {
      throw Exception('Greška prilikom kreiranja karte.');
    }
  }
  
  Future<TicketType?> updateTicketType({
    required int id,
    required double price,
    required String name,
    String? description,
  }) async {
    try {
      final data = {
        'id': id,
        'price': price,
        'name': name,
        'description': description ?? '',
      };
      
      final response = await _apiService.put('TicketType/$id', data);

        final ticketType = TicketType(
          id: response['id'],
          name: response['name'],
          price: (response['price'] as num).toDouble(),
          description: response['description'] ?? '',
          eventId: response['eventId'],
          initialQuantity: response['initialQuantity'],
          currentQuantity: response['currentQuantity'],
        );
        return ticketType;
    } catch (e) {
      throw Exception('Greška prilikom ažuriranja karte.');
    }
  }
  
  Future<bool> deleteTicketType(int id) async {
    try {
      await _apiService.delete('TicketType/$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteEvent(int id) async {
    try {
      await _apiService.delete('Event/$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<TicketType>> batchCreateTicketTypes({
    required int eventId,
    required List<Map<String, dynamic>> ticketTypes,
  }) async {    
    final List<TicketType> createdTypes = [];
    
    for (int i = 0; i < ticketTypes.length; i++) {
      final data = ticketTypes[i];
      final ticketData = {
        'eventId': eventId,
        'price': data['price'],
        'name': data['name'],
        'description': data['description'] ?? '',
        'initialQuantity': data['initialQuantity'],
        'userId': data['userId'],
      };
      
      try {
        final response = await _apiService.post('TicketType', ticketData);
        
        if (response.containsKey('id')) {
          final ticketType = TicketType(
            id: response['id'],
            name: response['name'],
            price: (response['price'] as num).toDouble(),
            description: response['description'] ?? '',
            eventId: response['eventId'],
            initialQuantity: response['initialQuantity'],
            currentQuantity: response['currentQuantity'],
          );
          
          createdTypes.add(ticketType);
        }
      } catch (e) {
        throw Exception('Greška prilikom kreiranja karte.');
      }
    }
    
    return createdTypes;
  }

  Event _mapEventFromBackend(dynamic eventData) {
    String? coverImageUrl;
    
    // Check if event has an image
    dynamic imageData = eventData['coverImage'];
    
    if (imageData != null) {
      // Get the event ID to create the image URL
      int eventId = eventData['id'] ?? 0;
      if (eventId > 0) {
        coverImageUrl = '${ApiService.baseUrl}/Event/$eventId/image';
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