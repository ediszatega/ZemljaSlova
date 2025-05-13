import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/ticket_type.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  final EventService _eventService;
  
  EventProvider(this._eventService);
  
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => [..._events];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _eventService.fetchEvents();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Event?> getEventById(int id) async {
    try {
      return await _eventService.getEventById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Add new event with ticket types
  Future<Event?> addEventWithTicketTypes({
    required String title,
    required String description,
    String? location,
    required DateTime startAt,
    required DateTime endAt,
    String? organizer,
    String? lecturers,
    List<int>? coverImage,
    int? maxNumberOfPeople,
    required List<Map<String, dynamic>> ticketTypes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Step 1: Create the event
      var newEvent = await _eventService.addEvent(
        title: title,
        description: description,
        location: location,
        startAt: startAt,
        endAt: endAt,
        organizer: organizer,
        lecturers: lecturers,
        coverImage: coverImage,
        maxNumberOfPeople: maxNumberOfPeople,
      );
      
      if (newEvent == null) {
        _error = 'Failed to create event';
        _isLoading = false;
        notifyListeners();
        return null;
      }
      
      // Step 2: Create ticket types for the event
      final createdTicketTypes = await _eventService.batchCreateTicketTypes(
        eventId: newEvent.id,
        ticketTypes: ticketTypes,
      );
      
      // Check if all ticket types were created
      if (createdTicketTypes.length < ticketTypes.length) {
        _error = 'Created event but only ${createdTicketTypes.length} of ${ticketTypes.length} ticket types were saved';
      }
      
      try {
        final refreshedEvent = await _eventService.getEventById(newEvent.id);
        
        _events.add(refreshedEvent);
        _isLoading = false;
        notifyListeners();
        return refreshedEvent;
      } catch (e) {
        debugPrint('Error refreshing event: $e');
        _events.add(newEvent);
        _isLoading = false;
        notifyListeners();
        // We return the event anyway since it was created
        return newEvent;
      }
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  Future<TicketType?> addTicketType({
    required int eventId,
    required double price,
    required String name,
    String? description,
  }) {
    return _eventService.addTicketType(
      eventId: eventId,
      price: price,
      name: name,
      description: description,
    );
  }
  
  Future<Event?> updateEventWithTicketTypes({
    required int eventId,
    required String title,
    required String description,
    String? location,
    required DateTime startAt,
    required DateTime endAt,
    String? organizer,
    String? lecturers,
    List<int>? coverImage,
    int? maxNumberOfPeople,
    required List<Map<String, dynamic>> ticketTypes,
    required List<int> ticketTypesToDelete,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      var updatedEvent = await _eventService.updateEvent(
        id: eventId,
        title: title,
        description: description,
        location: location,
        startAt: startAt,
        endAt: endAt,
        organizer: organizer,
        lecturers: lecturers,
        coverImage: coverImage,
        maxNumberOfPeople: maxNumberOfPeople,
      );
      
      if (updatedEvent == null) {
        _error = 'Failed to update event';
        _isLoading = false;
        notifyListeners();
        return null;
      }
      
      for (var ticketTypeId in ticketTypesToDelete) {
        await _eventService.deleteTicketType(ticketTypeId);
      }
      
      for (var ticketTypeData in ticketTypes) {
        if (ticketTypeData.containsKey('id') && ticketTypeData['id'] != null) {
          await _eventService.updateTicketType(
            id: ticketTypeData['id'],
            price: ticketTypeData['price'],
            name: ticketTypeData['name'],
            description: ticketTypeData['description'],
          );
        } else {
          await _eventService.addTicketType(
            eventId: eventId,
            price: ticketTypeData['price'],
            name: ticketTypeData['name'],
            description: ticketTypeData['description'],
          );
        }
      }
      
      try {
        final refreshedEvent = await _eventService.getEventById(eventId);
        
        final index = _events.indexWhere((event) => event.id == eventId);
        if (index >= 0) {
          _events[index] = refreshedEvent;
        }
        
        _isLoading = false;
        notifyListeners();
        return refreshedEvent;
      } catch (e) {
        debugPrint('Error refreshing event: $e');
        _isLoading = false;
        notifyListeners();

        return updatedEvent;
      }
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
} 