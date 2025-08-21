import 'package:json_annotation/json_annotation.dart';

part 'books_rented_report.g.dart';

@JsonSerializable()
class BooksRentedReport {
  @JsonKey(name: 'startDate')
  final DateTime startDate;
  
  @JsonKey(name: 'endDate')
  final DateTime endDate;
  
  @JsonKey(name: 'totalBooksRented')
  final int totalBooksRented;
  
  @JsonKey(name: 'totalActiveRentals')
  final int totalActiveRentals;
  
  @JsonKey(name: 'totalOverdueRentals')
  final int totalOverdueRentals;
  
  @JsonKey(name: 'totalTransactions')
  final int totalTransactions;
  
  @JsonKey(name: 'transactions')
  final List<BookRentedTransaction> transactions;
  
  @JsonKey(name: 'bookSummaries')
  final List<BookRentedSummary> bookSummaries;
  
  @JsonKey(name: 'reportPeriod')
  final String reportPeriod;

  BooksRentedReport({
    required this.startDate,
    required this.endDate,
    required this.totalBooksRented,
    required this.totalActiveRentals,
    required this.totalOverdueRentals,
    required this.totalTransactions,
    required this.transactions,
    required this.bookSummaries,
    required this.reportPeriod,
  });

  factory BooksRentedReport.fromJson(Map<String, dynamic> json) => _$BooksRentedReportFromJson(json);
  Map<String, dynamic> toJson() => _$BooksRentedReportToJson(this);
}

@JsonSerializable()
class BookRentedTransaction {
  final int id;
  
  @JsonKey(name: 'bookTitle')
  final String bookTitle;
  
  @JsonKey(name: 'authorNames')
  final String authorNames;
  
  final int quantity;
  
  @JsonKey(name: 'rentedDate')
  final DateTime rentedDate;
  
  @JsonKey(name: 'returnDate')
  final DateTime? returnDate;
  
  @JsonKey(name: 'dueDate')
  final DateTime dueDate;
  
  @JsonKey(name: 'customerName')
  final String customerName;
  
  @JsonKey(name: 'employeeName')
  final String employeeName;
  
  @JsonKey(name: 'isOverdue')
  final bool isOverdue;
  
  @JsonKey(name: 'isReturned')
  final bool isReturned;
  
  @JsonKey(name: 'daysOverdue')
  final int daysOverdue;

  BookRentedTransaction({
    required this.id,
    required this.bookTitle,
    required this.authorNames,
    required this.quantity,
    required this.rentedDate,
    this.returnDate,
    required this.dueDate,
    required this.customerName,
    required this.employeeName,
    required this.isOverdue,
    required this.isReturned,
    required this.daysOverdue,
  });

  factory BookRentedTransaction.fromJson(Map<String, dynamic> json) => _$BookRentedTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$BookRentedTransactionToJson(this);
}

@JsonSerializable()
class BookRentedSummary {
  @JsonKey(name: 'bookId')
  final int bookId;
  
  @JsonKey(name: 'bookTitle')
  final String bookTitle;
  
  @JsonKey(name: 'authorNames')
  final String authorNames;
  
  @JsonKey(name: 'totalTimesRented')
  final int totalTimesRented;
  
  @JsonKey(name: 'totalQuantityRented')
  final int totalQuantityRented;
  
  @JsonKey(name: 'activeRentals')
  final int activeRentals;
  
  @JsonKey(name: 'overdueRentals')
  final int overdueRentals;

  BookRentedSummary({
    required this.bookId,
    required this.bookTitle,
    required this.authorNames,
    required this.totalTimesRented,
    required this.totalQuantityRented,
    required this.activeRentals,
    required this.overdueRentals,
  });

  factory BookRentedSummary.fromJson(Map<String, dynamic> json) => _$BookRentedSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$BookRentedSummaryToJson(this);
}
