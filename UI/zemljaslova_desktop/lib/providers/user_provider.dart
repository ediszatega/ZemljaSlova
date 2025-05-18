import 'package:flutter/material.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  
  UserProvider(this._userService);
  
  UserService get userService => _userService;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  Future<bool> changePassword(
    int userId,
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      final result = await _userService.changePassword(
        userId,
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      );
      
      _isLoading = false;
      
      if (result) {
        _successMessage = 'Lozinka je uspješno promijenjena.';
        notifyListeners();
        return true;
      } else {
        _error = 'Neuspješna promjena lozinke. Molimo provjerite trenutnu lozinku.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void resetMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
} 