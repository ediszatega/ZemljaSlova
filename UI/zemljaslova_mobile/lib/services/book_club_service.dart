import '../models/user_book_club.dart';
import '../models/user_book_club_transaction.dart';
import 'api_service.dart';

class BookClubService {
  final ApiService _apiService;
  
  BookClubService(this._apiService);
  
  Future<Map<String, dynamic>?> getCurrentYearPoints(int memberId) async {
    try {
      final result = await _apiService.get('BookClubPoints/member/$memberId/current');
      return result;
    } catch (e) {
      throw Exception('Greška pri učitavanju podataka o Klubu čitalaca');
    }
  }

  Future<Map<String, dynamic>?> getYearPoints(int memberId, int year) async {
    try {
      return await _apiService.get('BookClubPoints/member/$memberId/year/$year');
    } catch (e) {
      throw Exception('Greška pri učitavanju podataka o Klubu čitalaca');
    }
  }

  Future<List<UserBookClubTransaction>?> getTransactionsForYear(int memberId, int year) async {
    try {
      return await _apiService.get('BookClubPoints/member/$memberId/transactions/$year');
    } catch (e) {
      throw Exception('Greška pri učitavanju transakcija');
    }
  }

  Future<List<UserBookClub>?> getMemberHistory(int memberId) async {
    try {
      final result = await _apiService.get('BookClubPoints/member/$memberId/history');
      
      if (result is List) {
        return result.map((item) => UserBookClub.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      throw Exception('Greška pri učitavanju istorije');
    }
  }
}
