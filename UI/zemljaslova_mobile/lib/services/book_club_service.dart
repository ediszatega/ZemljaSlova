import 'package:flutter/foundation.dart';
import '../models/user_book_club.dart';
import '../models/user_book_club_transaction.dart';
import 'api_service.dart';

class BookClubService {
  final ApiService _apiService;
  
  BookClubService(this._apiService);
  
  Future<Map<String, dynamic>?> getCurrentYearPoints(int memberId) async {
    try {
      final response = await _apiService.get('BookClubPoints/member/$memberId/current');
      return response;
    } catch (e) {
      debugPrint('Failed to get current year points: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getYearPoints(int memberId, int year) async {
    try {
      final response = await _apiService.get('BookClubPoints/member/$memberId/year/$year');
      return response;
    } catch (e) {
      debugPrint('Failed to get year points: $e');
      return null;
    }
  }

  Future<List<UserBookClubTransaction>?> getTransactionsForYear(int memberId, int year) async {
    try {
      final response = await _apiService.get('BookClubPoints/member/$memberId/transactions/$year');
      
      if (response != null && response is List) {
        return response.map<UserBookClubTransaction>((json) => UserBookClubTransaction.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get transactions for year: $e');
      return [];
    }
  }

  Future<List<UserBookClub>?> getMemberHistory(int memberId) async {
    try {
      final response = await _apiService.get('BookClubPoints/member/$memberId/history');
      
      if (response != null && response is List) {
        return response.map<UserBookClub>((json) => UserBookClub.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get member history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> testBookClubPoints() async {
    try {
      final response = await _apiService.get('BookClubPoints/test');
      return response;
    } catch (e) {
      debugPrint('Failed to test Book Club points: $e');
      return null;
    }
  }
}
