import 'package:flutter/material.dart';
import '../models/member.dart';
import '../services/member_service.dart';

class MemberProvider with ChangeNotifier {
  final MemberService _memberService;
  Member? _currentMember;
  bool _isLoading = false;
  String? _error;

  MemberProvider({required MemberService memberService}) 
      : _memberService = memberService;

  Member? get currentMember => _currentMember;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> registerMember({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    String? gender,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final member = await _memberService.createMember(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      if (member != null) {
        _currentMember = member;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create member account');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> getMember(int id) async {
    _setLoading(true);
    _clearError();

    try {
      final member = await _memberService.getMember(id);
      
      if (member != null) {
        _currentMember = member;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Member not found');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateMember({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    String? gender,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final member = await _memberService.updateMember(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      if (member != null) {
        _currentMember = member;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update member');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void clearMember() {
    _currentMember = null;
    _clearError();
    notifyListeners();
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
} 