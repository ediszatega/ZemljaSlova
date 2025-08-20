import 'package:flutter/foundation.dart';
import '../models/user_book_club.dart';
import '../models/user_book_club_transaction.dart';
import '../services/book_club_service.dart';

class BookClubProvider with ChangeNotifier {
  final BookClubService _bookClubService;
  
  BookClubProvider(this._bookClubService);
  
  Map<String, dynamic>? _currentYearData;
  List<UserBookClubTransaction>? _currentYearTransactions;
  List<UserBookClub>? _memberHistory;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get currentYearData => _currentYearData;
  List<UserBookClubTransaction>? get currentYearTransactions => _currentYearTransactions;
  List<UserBookClub>? get memberHistory => _memberHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get currentYearPoints => _currentYearData?['totalPoints'] ?? 0;
  int get currentYear => _currentYearData?['year'] ?? DateTime.now().year;

  Future<void> loadCurrentYearData(int memberId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final data = await _bookClubService.getCurrentYearPoints(memberId);
      if (data != null) {
        _currentYearData = data;
        notifyListeners();
      }
    } catch (e) {
      _setError('Greška pri učitavanju podataka o Klubu čitalaca: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentYearTransactions(int memberId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final transactions = await _bookClubService.getTransactionsForYear(memberId, DateTime.now().year);
      if (transactions != null) {
        _currentYearTransactions = transactions;
        notifyListeners();
      }
    } catch (e) {
      _setError('Greška pri učitavanju transakcija: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMemberHistory(int memberId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final history = await _bookClubService.getMemberHistory(memberId);
      if (history != null) {
        _memberHistory = history;
        notifyListeners();
      }
    } catch (e) {
      _setError('Greška pri učitavanju istorije: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshData(int memberId) async {
    await Future.wait([
      loadCurrentYearData(memberId),
      loadCurrentYearTransactions(memberId),
      loadMemberHistory(memberId),
    ]);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _currentYearData = null;
    _currentYearTransactions = null;
    _memberHistory = null;
    _error = null;
    notifyListeners();
  }
}
