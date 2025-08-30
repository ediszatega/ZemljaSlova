import 'dart:async';
import 'package:flutter/material.dart';
import '../models/membership.dart';
import '../models/membership_filters.dart';
import '../services/membership_service.dart';

class MembershipProvider with ChangeNotifier {
  final MembershipService _membershipService;
  
  MembershipProvider(this._membershipService);
  
  List<Membership> _memberships = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;

  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalCount = 0;
  
  MembershipFilters _filters = const MembershipFilters();
  MembershipFilters get filters => _filters;
  
  String _searchQuery = '';
  Timer? _searchDebounceTimer;

  List<Membership> get memberships => [..._memberships];
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  int get totalPages => (_totalCount / _pageSize).ceil();
  bool get hasPreviousPage => _currentPage > 0;
  bool get hasNextPage => (_currentPage + 1) < totalPages;
  bool get shouldShowPagination => _totalCount > _pageSize;

  Future<void> fetchMemberships({
    MembershipFilters? filters,
    bool includeMember = true,
    bool resetPage = true,
    String? name,
  }) async {
    if (resetPage) {
      _currentPage = 0;
    }
    
    if (filters != null) {
      _filters = filters;
    }
    
    if (_memberships.isNotEmpty && resetPage) {
      _isUpdating = true;
    } else {
      _isLoading = true;
    }
    _error = null;
    notifyListeners();
    
    try {
      final result = await _membershipService.fetchMemberships(
        filters: _filters.toQueryParams(),
        includeMember: includeMember,
        page: _currentPage,
        pageSize: _pageSize,
        name: name ?? (_searchQuery.isNotEmpty ? _searchQuery : null),
      );
      
      if (result != null) {
        final membershipsList = result['memberships'] as List;
        final totalCount = result['totalCount'] as int;
        
        if (resetPage) {
          _memberships = membershipsList.cast<Membership>();
        } else {
          _memberships.addAll(membershipsList.cast<Membership>());
        }
        
        _totalCount = totalCount;
      }
      
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
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    
    _searchDebounceTimer?.cancel();
    
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchMemberships(resetPage: true);
    });
  }

  void setFilters(MembershipFilters filters) {
    _filters = filters;
    fetchMemberships(resetPage: true);
  }

  void clearFilters() {
    _filters = const MembershipFilters();
    fetchMemberships(resetPage: true);
  }
  
  void clearSearch() {
    _searchQuery = '';
    _searchDebounceTimer?.cancel();
    _memberships.clear();
    fetchMemberships(resetPage: true);
  }
  
  String get searchQuery => _searchQuery;
  
  // Pagination methods
  Future<void> nextPage() async {
    if (hasNextPage && !_isLoading) {
      _currentPage++;
      await _fetchWithCurrentFilters();
    }
  }
  
  Future<void> previousPage() async {
    if (hasPreviousPage && !_isLoading) {
      _currentPage--;
      await _fetchWithCurrentFilters();
    }
  }
  
  // Helper method to refetch with stored filters
  Future<void> _fetchWithCurrentFilters() async {
    await fetchMemberships(
      filters: _filters,
      resetPage: false, // Don't reset page since we're navigating
    );
  }

  Future<Membership?> getMembershipById(int id) async {
    try {
      return await _membershipService.getMembershipById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Membership?> getActiveMembership(int memberId) async {
    try {
      return await _membershipService.getActiveMembership(memberId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Membership>> getMemberMemberships(int memberId) async {
    try {
      return await _membershipService.getMemberMemberships(memberId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<bool> createMembershipByAdmin({
    required int memberId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final membership = await _membershipService.createMembershipByAdmin(
        memberId: memberId,
        startDate: startDate,
        endDate: endDate,
      );

      if (membership != null) {
        await fetchMemberships(includeMember: true);
        return true;
      }

      _error = 'Failed to create admin membership';
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

  Future<bool> createMembershipByMember({
    required int memberId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final membership = await _membershipService.createMembershipByMember(
        memberId: memberId,
      );

      if (membership != null) {
        await fetchMemberships(includeMember: true);
        return true;
      }

      _error = 'Failed to create member membership';
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

  Future<bool> updateMembership(int id, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _membershipService.updateMembership(
        id,
        startDate: startDate,
        endDate: endDate,
      );

      if (success) {
        // Refresh the list to get updated data
        await fetchMemberships();
        return true;
      }

      _error = 'Failed to update membership';
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

  Future<bool> deleteMembership(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _membershipService.deleteMembership(id);

      if (success) {
        _memberships.removeWhere((membership) => membership.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Brisanje članarine nije uspjelo.';
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper getters for filtering
  List<Membership> get activeMemberships => _memberships.where((m) => m.isActive).toList();
  List<Membership> get expiredMemberships => _memberships.where((m) => m.isExpired).toList();
  List<Membership> get inactiveMemberships => _memberships.where((m) => !m.isActive && !m.isExpired).toList();
} 