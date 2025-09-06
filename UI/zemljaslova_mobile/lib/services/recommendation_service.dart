import '../models/recommendation.dart';
import '../models/book.dart';
import 'api_service.dart';
import 'book_service.dart';

class RecommendationService {
  final ApiService _apiService;
  final BookService _bookService;
  
  RecommendationService(this._apiService, this._bookService);
  
  Future<List<Book>> getRecommendedBooksForMember(int memberId) async {
    try {
      // First, clear existing recommendations and generate new ones
      final response = await _apiService.get('Recommendation/GenerateRecommendations/$memberId');
      
      if (response != null) {
        List<Book> recommendedBooks = [];
        
        // Parse recommendations response
        List<dynamic> recommendationsList = response is List ? response : [];
        
        // Get book details for each recommendation
        for (var recommendationData in recommendationsList) {
          try {
            int bookId = recommendationData['bookId'] ?? 0;
            if (bookId > 0) {
              Book? book = await _bookService.getBookById(bookId);
              if (book != null && book.bookPurpose == BookPurpose.sell) {
                recommendedBooks.add(book);
              }
            }
          } catch (e) {
            // Continue with other books if one fails
            continue;
          }
        }
        
        return recommendedBooks;
      }
      
      return [];
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }
  
  Future<List<Recommendation>> getRecommendationsForMember(int memberId) async {
    try {
      final response = await _apiService.get('Recommendation?MemberId=$memberId');
      
      if (response != null) {
        final recommendationsList = response['resultList'] as List? ?? [];
        
        final recommendations = recommendationsList
            .map((recommendationJson) => _mapRecommendationFromBackend(recommendationJson))
            .toList();
            
        return recommendations;
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  Recommendation _mapRecommendationFromBackend(dynamic recommendationData) {
    return Recommendation(
      id: recommendationData['id'] ?? 0,
      memberId: recommendationData['memberId'] ?? 0,
      bookId: recommendationData['bookId'] ?? 0,
      book: recommendationData['book'] != null 
          ? _bookService.mapBookFromBackend(recommendationData['book'])
          : null,
    );
  }
}
