import 'package:flutter/material.dart';
import '../models/favourite.dart';
import '../services/favourite_service.dart';

class FavouriteProvider with ChangeNotifier {
  final FavouriteService _favouriteService;
  
  FavouriteProvider(this._favouriteService);
  
  List<Favourite> _favourites = [];
  bool _isLoading = false;
  String? _error;
  
  // For tracking favourite status of individual books
  Map<int, bool> _favouriteStatus = {};

  List<Favourite> get favourites => [..._favourites];
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool isFavourite(int bookId) {
    return _favouriteStatus[bookId] ?? false;
  }

  Future<void> fetchFavourites(int memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favourites = await _favouriteService.fetchFavouritesByMemberId(memberId);
      
      // Update favourite status map
      _favouriteStatus.clear();
      for (var favourite in _favourites) {
        _favouriteStatus[favourite.bookId] = true;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> addToFavourites(int memberId, int bookId) async {
    try {
      final success = await _favouriteService.addToFavourites(memberId, bookId);
      
      if (success) {
        _favouriteStatus[bookId] = true;
        // Refresh favourites list to get the updated data
        await fetchFavourites(memberId);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> removeFromFavourites(int memberId, int bookId) async {
    try {
      final success = await _favouriteService.removeFromFavourites(memberId, bookId);
      
      if (success) {
        _favouriteStatus[bookId] = false;
        // Remove from local list
        _favourites.removeWhere((favourite) => favourite.bookId == bookId);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> toggleFavourite(int memberId, int bookId) async {
    final isCurrentlyFavourite = isFavourite(bookId);
    
    if (isCurrentlyFavourite) {
      await removeFromFavourites(memberId, bookId);
    } else {
      await addToFavourites(memberId, bookId);
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 