import 'package:flutter/material.dart';
import '../models/membership.dart';
import '../services/membership_service.dart';

class MembershipProvider with ChangeNotifier {
  final MembershipService _membershipService;
  Membership? _activeMembership;
  List<Membership> _memberships = [];
  bool _isLoading = false;
  String? _error;

  MembershipProvider({required MembershipService membershipService}) 
      : _membershipService = membershipService;

  Membership? get activeMembership => _activeMembership;
  List<Membership> get memberships => _memberships;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveMembership => _activeMembership != null && _activeMembership!.isActive;

  Future<bool> getActiveMembership(int memberId) async {
    _setLoading(true);
    _clearError();

    try {
      final membership = await _membershipService.getActiveMembership(memberId);
      
      if (membership != null) {
        _activeMembership = membership;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _activeMembership = null;
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> getMemberMemberships(int memberId) async {
    _setLoading(true);
    _clearError();

    try {
      final memberships = await _membershipService.getMemberMemberships(memberId);
      
      _memberships = memberships;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> createMembership(int memberId) async {
    _setLoading(true);
    _clearError();

    try {
      final membership = await _membershipService.createMembershipByMember(memberId);
      
      if (membership != null) {
        _activeMembership = membership;
        _memberships.insert(0, membership); // Add to beginning of list
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Greška prilikom kreiranja članstva.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearMembership() {
    _activeMembership = null;
    _memberships.clear();
    _error = null;
    notifyListeners();
  }
}

