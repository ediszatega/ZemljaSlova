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
      final newEvent = await _eventService.addEvent(
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
      bool allTicketTypesCreated = true;
      
      for (var ticketTypeData in ticketTypes) {
        final ticketType = await _eventService.addTicketType(
          eventId: newEvent.id,
          price: ticketTypeData['price'],
          name: ticketTypeData['name'],
          description: ticketTypeData['description'],
        );
        
        if (ticketType == null) {
          allTicketTypesCreated = false;
          break;
        }
      }
      
      if (!allTicketTypesCreated) {
        _error = 'Created event but failed to create some ticket types';
        _isLoading = false;
        notifyListeners();
        // We return the event anyway since it was created
        return newEvent;
      }
      
      // Add event to list and notify
      _events.add(newEvent);
      _isLoading = false;
      notifyListeners();
      return newEvent;
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Get ticket types for an event
  Future<List<TicketType>> getTicketTypesForEvent(int eventId) async {
    try {
      return await _eventService.getTicketTypesForEvent(eventId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
} 