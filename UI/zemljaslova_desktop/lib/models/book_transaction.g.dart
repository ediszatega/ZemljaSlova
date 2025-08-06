// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookTransaction _$BookTransactionFromJson(Map<String, dynamic> json) =>
    BookTransaction(
      id: (json['id'] as num?)?.toInt(),
      activityTypeId: (json['activityTypeId'] as num).toInt(),
      bookId: (json['bookId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: (json['userId'] as num).toInt(),
      data: json['data'] as String?,
    );

Map<String, dynamic> _$BookTransactionToJson(BookTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activityTypeId': instance.activityTypeId,
      'bookId': instance.bookId,
      'quantity': instance.quantity,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
      'data': instance.data,
    };
