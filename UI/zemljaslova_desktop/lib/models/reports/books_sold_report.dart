import 'package:json_annotation/json_annotation.dart';

part 'books_sold_report.g.dart';

@JsonSerializable()
class BooksSoldReport {
  @JsonKey(name: 'startDate')
  final DateTime startDate;
  
  @JsonKey(name: 'endDate')
  final DateTime endDate;
  
  @JsonKey(name: 'totalBooksSold')
  final int totalBooksSold;
  
  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;
  
  @JsonKey(name: 'totalTransactions')
  final int totalTransactions;
  
  @JsonKey(name: 'transactions')
  final List<BookSoldTransaction> transactions;
  
  @JsonKey(name: 'bookSummaries')
  final List<BookSoldSummary> bookSummaries;
  
  @JsonKey(name: 'reportPeriod')
  final String reportPeriod;

  BooksSoldReport({
    required this.startDate,
    required this.endDate,
    required this.totalBooksSold,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.transactions,
    required this.bookSummaries,
    required this.reportPeriod,
  });

  factory BooksSoldReport.fromJson(Map<String, dynamic> json) => _$BooksSoldReportFromJson(json);
  Map<String, dynamic> toJson() => _$BooksSoldReportToJson(this);
}

@JsonSerializable()
class BookSoldTransaction {
  final int id;
  
  @JsonKey(name: 'bookTitle')
  final String bookTitle;
  
  @JsonKey(name: 'authorNames')
  final String authorNames;
  
  final int quantity;
  
  @JsonKey(name: 'unitPrice')
  final double unitPrice;
  
  @JsonKey(name: 'totalPrice')
  final double totalPrice;
  
  @JsonKey(name: 'soldDate')
  final DateTime soldDate;
  
  @JsonKey(name: 'employeeName')
  final String employeeName;
  
  @JsonKey(name: 'customerName')
  final String customerName;

  BookSoldTransaction({
    required this.id,
    required this.bookTitle,
    required this.authorNames,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.soldDate,
    required this.employeeName,
    required this.customerName,
  });

  factory BookSoldTransaction.fromJson(Map<String, dynamic> json) => _$BookSoldTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$BookSoldTransactionToJson(this);
}

@JsonSerializable()
class BookSoldSummary {
  @JsonKey(name: 'bookId')
  final int bookId;
  
  @JsonKey(name: 'bookTitle')
  final String bookTitle;
  
  @JsonKey(name: 'authorNames')
  final String authorNames;
  
  @JsonKey(name: 'totalQuantitySold')
  final int totalQuantitySold;
  
  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;
  
  @JsonKey(name: 'averagePrice')
  final double averagePrice;

  BookSoldSummary({
    required this.bookId,
    required this.bookTitle,
    required this.authorNames,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.averagePrice,
  });

  factory BookSoldSummary.fromJson(Map<String, dynamic> json) => _$BookSoldSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$BookSoldSummaryToJson(this);
}
