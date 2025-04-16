import 'package:flutter/material.dart';
import '../models/member.dart';

class MemberProvider with ChangeNotifier {
  List<Member> _members = [];
  bool _isLoading = false;
  String? _error;

  List<Member> get members => [..._members];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _members = List.generate(
        10,
        (index) => Member(
          id: index + 1,
          firstName: 'Ime${index + 1}',
          lastName: 'Prezime${index + 1}',
          email: 'korisnik${index + 1}@example.com',
          isActive: index % 3 != 0, // Every third user is inactive
        ),
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleMemberStatus(int memberId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final memberIndex = _members.indexWhere((member) => member.id == memberId);
      if (memberIndex >= 0) {
        final member = _members[memberIndex];
        final updatedMember = Member(
          id: member.id,
          firstName: member.firstName,
          lastName: member.lastName,
          email: member.email,
          isActive: !member.isActive,
          profileImageUrl: member.profileImageUrl,
        );
        
        _members[memberIndex] = updatedMember;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 