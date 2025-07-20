import 'package:flutter/material.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  Map<String, dynamic>? _currentUserProfile;
  
  UserProvider(this._userService);
  
  UserService get userService => _userService;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;
  
  Future<bool> loadCurrentUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final profile = await _userService.getCurrentUserProfile();
      
      _isLoading = false;
      
      if (profile != null) {
        _currentUserProfile = profile;
        notifyListeners();
        return true;
      } else {
        _error = 'Nije moguće učitati podatke o korisniku. Provjerite da li ste zaposlenik.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Greška pri učitavanju profila: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> refreshUserProfile() async {
    return await loadCurrentUserProfile();
  }
  
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