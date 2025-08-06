import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/favourite.dart';
import '../models/book.dart';
import 'api_service.dart';

class FavouriteService {
  final ApiService _apiService;
  
  FavouriteService(this._apiService);
  
  Future<List<Favourite>> fetchFavouritesByMemberId(int memberId) async {
    try {
      final response = await _apiService.get('Favourite?MemberId=$memberId&IsBookIncluded=true');
      
      debugPrint('Favourites API response: $response');
      
      if (response != null) {
        final favouritesList = response['resultList'] as List;
        
        return favouritesList
            .map((favouriteJson) => _mapFavouriteFromBackend(favouriteJson))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to fetch favourites: $e');
      return [];
    }
  }
  
  Future<bool> addToFavourites(int memberId, int bookId) async {
    try {
      final requestBody = {
        'memberId': memberId,
        'bookId': bookId,
      };
      
      final response = await _apiService.post('Favourite', requestBody);
      
      if (response != null) {
        debugPrint('Successfully added to favourites');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to add to favourites: $e');
      return false;
    }
  }
  
  Future<bool> removeFromFavourites(int memberId, int bookId) async {
    try {
      final response = await _apiService.delete('Favourite/unfavourite?memberId=$memberId&bookId=$bookId');
      
      if (response != null) {
        debugPrint('Successfully removed from favourites');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to remove from favourites: $e');
      return false;
    }
  }
  
  Future<bool> isFavourite(int memberId, int bookId) async {
    try {
      final response = await _apiService.get('Favourite?MemberId=$memberId&BookId=$bookId');
      
      if (response != null) {
        final favouritesList = response['resultList'] as List;
        return favouritesList.isNotEmpty;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to check favourite status: $e');
      return false;
    }
  }

  Favourite _mapFavouriteFromBackend(dynamic favouriteData) {
    Book? book;
    
    if (favouriteData['book'] != null) {
      book = _mapBookFromBackend(favouriteData['book']);
    }

    return Favourite(
      id: favouriteData['id'] ?? 0,
      memberId: favouriteData['memberId'] ?? 0,
      bookId: favouriteData['bookId'] ?? 0,
      book: book,
    );
  }
  
  Book _mapBookFromBackend(dynamic bookData) {
    String? coverImageUrl;
    if (bookData['image'] != null) {
      if (bookData['image'] is List) {
        final bytes = List<int>.from(bookData['image']);
        coverImageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else if (bookData['image'] is String) {
        coverImageUrl = bookData['image'];
      }
    }

    bool isAvailable = bookData['isAvailable'] ?? false;
    int quantityInStock = bookData['quantityInStock'] ?? bookData['numberInStock'] ?? 0;
    
    String? description = bookData['description'];
    String? dateOfPublish;
    if (bookData['dateOfPublish'] != null) {
      final date = DateTime.parse(bookData['dateOfPublish']);
      dateOfPublish = '${date.day}.${date.month}.${date.year}';
    }
    int? edition = bookData['edition'];
    String? publisher = bookData['publisher'];
    BookPurpose? bookPurpose;
    if (bookData['bookPurpose'] != null) {
      final purposeValue = bookData['bookPurpose'] as int;
      bookPurpose = BookPurpose.values.firstWhere(
        (p) => p.index + 1 == purposeValue,
        orElse: () => BookPurpose.sell,
      );
    }
    int? numberOfPages = bookData['numberOfPages'];
    double? weight = bookData['weight']?.toDouble();
    String? dimensions = bookData['dimensions'];
    String? genre = bookData['genre'];
    String? binding = bookData['binding'];
    String? language = bookData['language'];

    return Book(
      id: bookData['id'] ?? 0,
      title: bookData['title'] ?? '',
      price: (bookData['price'] ?? 0).toDouble(),
      coverImageUrl: coverImageUrl,
      isAvailable: isAvailable,
      quantityInStock: quantityInStock,
      quantitySold: bookData['quantitySold'] ?? 0,
      description: description,
      dateOfPublish: dateOfPublish,
      edition: edition,
      publisher: publisher,
      bookPurpose: bookPurpose,
      numberOfPages: numberOfPages ?? 0,
      weight: weight,
      dimensions: dimensions,
      genre: genre,
      binding: binding,
      language: language,
      authorIds: [],
      authors: null,
    );
  }
} 