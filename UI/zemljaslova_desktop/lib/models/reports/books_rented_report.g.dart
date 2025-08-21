// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books_rented_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BooksRentedReport _$BooksRentedReportFromJson(
  Map<String, dynamic> json,
) => BooksRentedReport(
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  totalBooksRented: (json['totalBooksRented'] as num).toInt(),
  totalActiveRentals: (json['totalActiveRentals'] as num).toInt(),
  totalOverdueRentals: (json['totalOverdueRentals'] as num).toInt(),
  totalTransactions: (json['totalTransactions'] as num).toInt(),
  transactions:
      (json['transactions'] as List<dynamic>)
          .map((e) => BookRentedTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
  bookSummaries:
      (json['bookSummaries'] as List<dynamic>)
          .map((e) => BookRentedSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
  reportPeriod: json['reportPeriod'] as String,
);

Map<String, dynamic> _$BooksRentedReportToJson(BooksRentedReport instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalBooksRented': instance.totalBooksRented,
      'totalActiveRentals': instance.totalActiveRentals,
      'totalOverdueRentals': instance.totalOverdueRentals,
      'totalTransactions': instance.totalTransactions,
      'transactions': instance.transactions,
      'bookSummaries': instance.bookSummaries,
      'reportPeriod': instance.reportPeriod,
    };

BookRentedTransaction _$BookRentedTransactionFromJson(
  Map<String, dynamic> json,
) => BookRentedTransaction(
  id: (json['id'] as num).toInt(),
  bookTitle: json['bookTitle'] as String,
  authorNames: json['authorNames'] as String,
  quantity: (json['quantity'] as num).toInt(),
  rentedDate: DateTime.parse(json['rentedDate'] as String),
  returnDate:
      json['returnDate'] == null
          ? null
          : DateTime.parse(json['returnDate'] as String),
  dueDate: DateTime.parse(json['dueDate'] as String),
  customerName: json['customerName'] as String,
  employeeName: json['employeeName'] as String,
  isOverdue: json['isOverdue'] as bool,
  isReturned: json['isReturned'] as bool,
  daysOverdue: (json['daysOverdue'] as num).toInt(),
);

Map<String, dynamic> _$BookRentedTransactionToJson(
  BookRentedTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'bookTitle': instance.bookTitle,
  'authorNames': instance.authorNames,
  'quantity': instance.quantity,
  'rentedDate': instance.rentedDate.toIso8601String(),
  'returnDate': instance.returnDate?.toIso8601String(),
  'dueDate': instance.dueDate.toIso8601String(),
  'customerName': instance.customerName,
  'employeeName': instance.employeeName,
  'isOverdue': instance.isOverdue,
  'isReturned': instance.isReturned,
  'daysOverdue': instance.daysOverdue,
};

BookRentedSummary _$BookRentedSummaryFromJson(Map<String, dynamic> json) =>
    BookRentedSummary(
      bookId: (json['bookId'] as num).toInt(),
      bookTitle: json['bookTitle'] as String,
      authorNames: json['authorNames'] as String,
      totalTimesRented: (json['totalTimesRented'] as num).toInt(),
      totalQuantityRented: (json['totalQuantityRented'] as num).toInt(),
      activeRentals: (json['activeRentals'] as num).toInt(),
      overdueRentals: (json['overdueRentals'] as num).toInt(),
    );

Map<String, dynamic> _$BookRentedSummaryToJson(BookRentedSummary instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'bookTitle': instance.bookTitle,
      'authorNames': instance.authorNames,
      'totalTimesRented': instance.totalTimesRented,
      'totalQuantityRented': instance.totalQuantityRented,
      'activeRentals': instance.activeRentals,
      'overdueRentals': instance.overdueRentals,
    };
