import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/ticket_type.dart';
import '../services/event_service.dart';
import '../widgets/paginated_data_widget.dart';

class EventProvider with ChangeNotifier implements PaginatedDataProvider<Event> {
  final EventService _eventService;
  
  EventProvider(this._eventService);
  
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  
  // Pagination state
  int _currentPage = 0;
  int _pageSize = 4;
  int _totalCount = 0;
  bool _hasMoreData = true;

  List<Event> get events => [..._events];
  
  // PaginatedDataProvider interface implementation
  @override
  List<Event> get items => events;
  
  bool get isLoading => _isLoading;
  @override
  bool get isInitialLoading => _isLoading && _events.isEmpty;
  @override
  bool get isLoadingMore => _isLoading && _events.isNotEmpty;
  @override
  String? get error => _error;
  int get currentPage => _currentPage;
  @override
  int get pageSize => _pageSize;
  @override
  int get totalCount => _totalCount;
  @override
  bool get hasMoreData => _hasMoreData;
  int get totalPages => (_totalCount / _pageSize).ceil();

  Future<void> fetchEvents({bool isTicketTypeIncluded = true, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _events.clear();
      _hasMoreData = true;
      _error = null;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _eventService.fetchEvents(
        isTicketTypeIncluded: isTicketTypeIncluded,
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      final List<Event> newEvents = result['events'] as List<Event>;
      _totalCount = result['totalCount'] as int;
      
      if (refresh || _events.isEmpty) {
        _events = newEvents;
      } else {
        _events.addAll(newEvents);
      }
      
      _hasMoreData = _events.length < _totalCount;
      
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  @override
  Future<void> loadMore({bool isTicketTypeIncluded = true}) async {
    if (_isLoading || !_hasMoreData) return;
    
    _currentPage++;
    await fetchEvents(isTicketTypeIncluded: isTicketTypeIncluded, refresh: false);
  }
  
  @override
  Future<void> refresh({bool isTicketTypeIncluded = true}) async {
    await fetchEvents(isTicketTypeIncluded: isTicketTypeIncluded, refresh: true);
  }
  
  @override
  void setPageSize(int newPageSize) {
    if (newPageSize != _pageSize) {
      _pageSize = newPageSize;
      refresh();
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
        
        // Refresh to get updated pagination
        await refresh();
        _isLoading = false;
        notifyListeners();
        return refreshedEvent;
      } catch (e) {
        debugPrint('Error refreshing event: $e');
        // Refresh to get updated pagination
        await refresh();
        _isLoading = false;
        notifyListeners();
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