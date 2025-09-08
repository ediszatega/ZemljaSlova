import '../models/book.dart';
import '../models/author.dart';
import '../models/discount.dart';
import 'api_service.dart';

class BookService {
  final ApiService _apiService;
  
  BookService(this._apiService);
  
  Future<Map<String, dynamic>> fetchBooks({
    bool isAuthorIncluded = true,
    int? page,
    int? pageSize,
    String? name,
    String? sortBy,
    String? sortOrder,
    Map<String, String>? filters,
    BookPurpose? bookPurpose,
  }) async {
    try {
      List<String> queryParams = ['IsAuthorIncluded=$isAuthorIncluded'];
      
      if (page != null) {
        queryParams.add('Page=$page');
      }
      
      if (pageSize != null) {
        queryParams.add('PageSize=$pageSize');
      }
      
      if (name != null && name.isNotEmpty) {
        queryParams.add('Title=${Uri.encodeComponent(name)}');
      }
      
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams.add('SortBy=${Uri.encodeComponent(sortBy)}');
      }
      
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams.add('SortOrder=${Uri.encodeComponent(sortOrder)}');
      }
      
      if (filters != null) {
        for (final entry in filters.entries) {
          queryParams.add('${entry.key}=${Uri.encodeComponent(entry.value)}');
        }
      }
      
      if (bookPurpose != null) {
        queryParams.add('BookPurpose=${bookPurpose.index + 1}');
      }
      
      final queryString = queryParams.join('&');
      final response = await _apiService.get('Book?$queryString');
            
      if (response != null) {
        final booksList = response['resultList'] as List;
        final totalCount = response['count'] as int;
        
        final books = booksList
            .map((bookJson) => mapBookFromBackend(bookJson))
            .toList();
            
        return {
          'books': books,
          'totalCount': totalCount,
        };
      }
      
      return {
        'books': <Book>[],
        'totalCount': 0,
      };
    } catch (e) {
      return {
        'books': <Book>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Book?> getBookById(int id) async {
      final response = await _apiService.get('Book/$id?IsAuthorIncluded=true');
      
      if (response != null) {
        return mapBookFromBackend(response);
      }
      
    throw Exception('Knjiga nije pronađena');
  }

  Book mapBookFromBackend(dynamic bookData) {
    String? coverImageUrl;
    
    // Check if book has an image
    dynamic imageData = bookData['image'];
    
    if (imageData != null) {
      // Get the book ID to create the image URL
      int bookId = bookData['id'] ?? 0;
      if (bookId > 0) {
        coverImageUrl = '${ApiService.baseUrl}/Book/$bookId/image';
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
    
    List<Author> authors = [];
    List<int> authorIds = [];
    
    if (bookData['authors'] != null && bookData['authors'] is List && (bookData['authors'] as List).isNotEmpty) {
      List<dynamic> authorsList = bookData['authors'];
      authors = authorsList.map((authorData) => Author(
        id: authorData['id'] ?? 0,
        firstName: authorData['firstName'] ?? '',
        lastName: authorData['lastName'] ?? '',
        dateOfBirth: authorData['dateOfBirth'] != null 
            ? DateTime.parse(authorData['dateOfBirth']).toString()
            : null,
        genre: authorData['genre'],
        biography: authorData['biography'],
      )).toList();
      
      authorIds = authors.map((author) => author.id).toList();
    }

    // Map discount information
    int? discountId = bookData['discountId'];
    double? discountedPrice = bookData['discountedPrice']?.toDouble();
    Discount? discount;
    
    if (bookData['discount'] != null) {
      final discountData = bookData['discount'];
      discount = Discount(
        id: discountData['id'] ?? 0,
        discountPercentage: (discountData['discountPercentage'] ?? 0).toDouble(),
        startDate: DateTime.parse(discountData['startDate']),
        endDate: DateTime.parse(discountData['endDate']),
        code: discountData['code'],
        name: discountData['name'],
        description: discountData['description'],
        scope: discountData['scope'] != null 
            ? DiscountScope.values.firstWhere(
                (s) => s.index + 1 == discountData['scope'],
                orElse: () => DiscountScope.book,
              )
            : DiscountScope.book,
        usageCount: discountData['usageCount'] ?? 0,
        maxUsage: discountData['maxUsage'],
        isActive: discountData['isActive'] ?? false,
      );
    }

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
      authorIds: authorIds,
      authors: authors.isNotEmpty ? authors : null,
      discountId: discountId,
      discountedPrice: discountedPrice,
      discount: discount,
    );
  }
} 