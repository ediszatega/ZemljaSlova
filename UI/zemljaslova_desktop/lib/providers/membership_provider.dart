import 'package:flutter/material.dart';
import '../models/membership.dart';
import '../services/membership_service.dart';

class MembershipProvider with ChangeNotifier {
  final MembershipService _membershipService;
  
  MembershipProvider(MembershipService membershipService) 
      : _membershipService = membershipService {
    print('MembershipProvider constructor called with service: $_membershipService');
    if (_membershipService == null) {
      print('ERROR: MembershipService is null!');
      throw ArgumentError('MembershipService cannot be null');
    }
  }
  
  List<Membership> _memberships = [];
  bool _isLoading = false;
  String? _error;

  List<Membership> get memberships => [..._memberships];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMemberships({
    bool? isActive,
    bool? isExpired,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
    bool includeMember = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _memberships = await _membershipService.fetchMemberships(
        isActive: isActive,
        isExpired: isExpired,
        startDateFrom: startDateFrom,
        startDateTo: startDateTo,
        endDateFrom: endDateFrom,
        endDateTo: endDateTo,
        includeMember: includeMember,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
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
        _memberships.add(membership);
        _isLoading = false;
        notifyListeners();
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
        _memberships.add(membership);
        _isLoading = false;
        notifyListeners();
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

      _error = 'Failed to delete membership';
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