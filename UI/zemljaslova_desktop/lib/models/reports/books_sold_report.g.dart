// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books_sold_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BooksSoldReport _$BooksSoldReportFromJson(Map<String, dynamic> json) =>
    BooksSoldReport(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalBooksSold: (json['totalBooksSold'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalTransactions: (json['totalTransactions'] as num).toInt(),
      transactions:
          (json['transactions'] as List<dynamic>)
              .map(
                (e) => BookSoldTransaction.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      bookSummaries:
          (json['bookSummaries'] as List<dynamic>)
              .map((e) => BookSoldSummary.fromJson(e as Map<String, dynamic>))
              .toList(),
      reportPeriod: json['reportPeriod'] as String,
    );

Map<String, dynamic> _$BooksSoldReportToJson(BooksSoldReport instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalBooksSold': instance.totalBooksSold,
      'totalRevenue': instance.totalRevenue,
      'totalTransactions': instance.totalTransactions,
      'transactions': instance.transactions,
      'bookSummaries': instance.bookSummaries,
      'reportPeriod': instance.reportPeriod,
    };

BookSoldTransaction _$BookSoldTransactionFromJson(Map<String, dynamic> json) =>
    BookSoldTransaction(
      id: (json['id'] as num).toInt(),
      bookTitle: json['bookTitle'] as String,
      authorNames: json['authorNames'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      soldDate: DateTime.parse(json['soldDate'] as String),
      employeeName: json['employeeName'] as String,
      customerName: json['customerName'] as String,
    );

Map<String, dynamic> _$BookSoldTransactionToJson(
  BookSoldTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'bookTitle': instance.bookTitle,
  'authorNames': instance.authorNames,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'totalPrice': instance.totalPrice,
  'soldDate': instance.soldDate.toIso8601String(),
  'employeeName': instance.employeeName,
  'customerName': instance.customerName,
};

BookSoldSummary _$BookSoldSummaryFromJson(Map<String, dynamic> json) =>
    BookSoldSummary(
      bookId: (json['bookId'] as num).toInt(),
      bookTitle: json['bookTitle'] as String,
      authorNames: json['authorNames'] as String,
      totalQuantitySold: (json['totalQuantitySold'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averagePrice: (json['averagePrice'] as num).toDouble(),
    );

Map<String, dynamic> _$BookSoldSummaryToJson(BookSoldSummary instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'bookTitle': instance.bookTitle,
      'authorNames': instance.authorNames,
      'totalQuantitySold': instance.totalQuantitySold,
      'totalRevenue': instance.totalRevenue,
      'averagePrice': instance.averagePrice,
    };
