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
} 