import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/recommendation.dart';
import '../services/recommendation_service.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationService _recommendationService;
  
  List<Book> _recommendedBooks = [];
  List<Recommendation> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  RecommendationProvider({required RecommendationService recommendationService}) 
      : _recommendationService = recommendationService;

  List<Book> get recommendedBooks => _recommendedBooks;
  List<Recommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecommendedBooks(int memberId) async {
    _setLoading(true);
    _clearError();

    try {
      final books = await _recommendationService.getRecommendedBooksForMember(memberId);
      _recommendedBooks = books;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Greška prilikom učitavanja preporučenih knjiga.');
    }
  }

  Future<void> loadRecommendations(int memberId) async {
    _setLoading(true);
    _clearError();

    try {
      final recommendations = await _recommendationService.getRecommendationsForMember(memberId);
      _recommendations = recommendations;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Greška prilikom učitavanja preporuka.');
    }
  }

  void clearRecommendations() {
    _recommendedBooks = [];
    _recommendations = [];
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
