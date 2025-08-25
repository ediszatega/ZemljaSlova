import 'api_service.dart';

class BookClubService {
  final ApiService _apiService;

  BookClubService({required ApiService apiService}) : _apiService = apiService;

  Future<int> getCurrentYearPoints(int memberId) async {
    try {      
      final response = await _apiService.get('BookClubPoints/member/$memberId/current');
      
      if (response != null && response is Map<String, dynamic>) {
        final points = response['totalPoints'] ?? 0;
        return points;
      }
      return await _calculatePointsFromTransactions(memberId);
      
    } catch (e) {
      try {
        return await _calculatePointsFromTransactions(memberId);
      } catch (fallbackError) {
        return 0;
      }
    }
  }

  Future<int> _calculatePointsFromTransactions(int memberId) async {
    try {
      final currentYear = DateTime.now().year;
      
      final response = await _apiService.get('BookClubPoints/member/$memberId/transactions/$currentYear');
      
      if (response != null && response is List) {
        int totalPoints = 0;
        for (final transaction in response) {
          if (transaction is Map<String, dynamic> && transaction['points'] != null) {
            totalPoints += (transaction['points'] as int);
          }
        }
        return totalPoints;
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getMemberBookClubData(int memberId) async {
    try {
      return await _apiService.get('BookClubPoints/member/$memberId');
    } catch (e) {
      throw Exception('Greška pri učitavanju podataka o Klubu čitalaca');
    }
  }

  Future<Map<String, dynamic>?> getLeaderboard({int page = 1, int pageSize = 20}) async {
    try {
      return await _apiService.get('BookClubPoints/leaderboard?page=$page&pageSize=$pageSize');
    } catch (e) {
      throw Exception('Greška pri učitavanju liderske tabele');
    }
  }
}
