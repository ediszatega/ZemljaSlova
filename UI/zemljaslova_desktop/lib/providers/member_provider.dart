import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/member_filters.dart';
import '../services/member_service.dart';
import '../widgets/paginated_data_widget.dart';
import '../utils/error_formatter.dart';

class MemberProvider with ChangeNotifier implements PaginatedDataProvider<Member> {
  final MemberService _memberService;
  
  MemberProvider(this._memberService);
  
  List<Member> _members = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  
  // Pagination state
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  bool _hasMoreData = true;
  
  // Search state
  String _searchQuery = '';
  Timer? _searchDebounceTimer;
  
  // Sorting state
  String _sortBy = 'name';
  String _sortOrder = 'asc';
  
  // Filter state
  MemberFilters _filters = const MemberFilters();

  List<Member> get members => [..._members];
  
  // PaginatedDataProvider interface implementation
  @override
  List<Member> get items => members;
  
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  @override
  bool get isInitialLoading => _isLoading && _members.isEmpty;
  @override
  bool get isLoadingMore => _isLoading && _members.isNotEmpty;
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
  MemberFilters get filters => _filters;

  Future<void> fetchMembers({bool isUserIncluded = true, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      if (_members.isEmpty) {
        _members.clear();
      }
      _hasMoreData = true;
      _error = null;
    }
    
    if (_members.isNotEmpty && refresh) {
      _isUpdating = true;
    } else {
      _isLoading = true;
    }
    notifyListeners();

    try {
      final result = await _memberService.fetchMembers(
        isUserIncluded: isUserIncluded,
        page: _currentPage,
        pageSize: _pageSize,
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        filters: _filters.toQueryParams(),
      );
      
      final List<Member> newMembers = result['members'] as List<Member>;
      _totalCount = result['totalCount'] as int;
      
      if (refresh) {
        _members = newMembers;
      } else {
        _members.addAll(newMembers);
      }
      
      _hasMoreData = _members.length < _totalCount;
      
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
  Future<void> loadMore({bool isUserIncluded = true}) async {
    if (_isLoading || !_hasMoreData) return;
    
    _currentPage++;
    await fetchMembers(isUserIncluded: isUserIncluded, refresh: false);
  }
  
  @override
  Future<void> refresh({bool isUserIncluded = true}) async {
    await fetchMembers(isUserIncluded: isUserIncluded, refresh: true);
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
    _members.clear();
    refresh();
  }
  
  void setFilters(MemberFilters filters) {
    _filters = filters;
    refresh();
  }
  
  void clearFilters() {
    _filters = const MemberFilters();
    refresh();
  }
  
  String get searchQuery => _searchQuery;

  Future<Member?> getMemberById(int id) async {
    try {
      return await _memberService.getMemberById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> addMember(
    String firstName,
    String lastName,
    String email,
    String password,
    DateTime dateOfBirth,
    String? gender, {
    Uint8List? imageBytes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final member = await _memberService.createMember(
        firstName,
        lastName,
        email,
        password,
        dateOfBirth,
        gender,
        imageBytes: imageBytes,
      );

      if (member != null) {
        // Refresh to get updated pagination
        await refresh();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to add member';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<Member?> updateMember(
    int id,
    String firstName,
    String lastName,
    String email,
    DateTime dateOfBirth,
    String? gender, {
    Uint8List? imageBytes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMember = await _memberService.updateMember(
        id,
        firstName,
        lastName,
        email,
        dateOfBirth,
        gender,
        imageBytes: imageBytes,
      );

      if (updatedMember != null) {
        final index = _members.indexWhere((member) => member.id == id);
        if (index >= 0) {
          _members[index] = updatedMember;
        }
        
        _isLoading = false;
        notifyListeners();
        return updatedMember;
      }

      _error = 'Failed to update member';
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  Future<bool> deleteMember(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _memberService.deleteMember(id);
      
      // Refresh to get updated pagination
      await refresh();
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorFormatter.formatException(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 