import 'package:flutter/material.dart';
import '../models/member.dart';
import '../services/member_service.dart';

class MemberProvider with ChangeNotifier {
  final MemberService _memberService;
  
  MemberProvider(this._memberService);
  
  List<Member> _members = [];
  bool _isLoading = false;
  String? _error;

  List<Member> get members => [..._members];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMembers({bool isUserIncluded = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await _memberService.fetchMembers(isUserIncluded: isUserIncluded);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

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
    String? gender,
  ) async {
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
      );

      if (member != null) {
        _members.add(member);
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
    String? gender,
  ) async {
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
} 