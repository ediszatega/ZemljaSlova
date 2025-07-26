import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../widgets/paginated_data_widget.dart';

class EventProvider with ChangeNotifier implements PaginatedDataProvider<Event> {
  final EventService _eventService;
  
  EventProvider(this._eventService);
  
  List<Event> _events = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  bool _hasMoreData = true;
  
  String _searchQuery = '';
  Timer? _searchDebounceTimer;
  
  // Sorting state
  String _sortBy = 'date';
  String _sortOrder = 'desc';

  List<Event> get events => [..._events];
  
  @override
  List<Event> get items => events;
  
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
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
  
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;

  Future<void> fetchEvents({bool isTicketTypeIncluded = true, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      if (_events.isEmpty) {
        _events.clear();
      }
      _hasMoreData = true;
      _error = null;
    }
    
    if (_events.isNotEmpty && refresh) {
      _isUpdating = true;
    } else {
      _isLoading = true;
    }
    notifyListeners();

    try {
      final result = await _eventService.fetchEvents(
        isTicketTypeIncluded: isTicketTypeIncluded,
        page: _currentPage,
        pageSize: _pageSize,
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
      
      final List<Event> newEvents = result['events'] as List<Event>;
      _totalCount = result['totalCount'] as int;
      
      if (refresh) {
        _events = newEvents;
      } else {
        _events.addAll(newEvents);
      }
      
      _hasMoreData = _events.length < _totalCount;
      
      _isLoading = false;
      _isUpdating = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isUpdating = false;
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
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    
    _searchDebounceTimer?.cancel();
    
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      refresh();
    });
  }
  
  void setSorting(String sortBy, String sortOrder) {
    if (_sortBy != sortBy || _sortOrder != sortOrder) {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
      refresh();
    }
  }
  
  void clearSearch() {
    _searchQuery = '';
    _searchDebounceTimer?.cancel();
    _events.clear();
    refresh();
  }
  
  String get searchQuery => _searchQuery;
  
  Future<Event?> getEventById(int id) async {
    try {
      return await _eventService.getEventById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
} 