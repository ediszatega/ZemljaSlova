// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_book_club_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBookClubTransaction _$UserBookClubTransactionFromJson(
  Map<String, dynamic> json,
) => UserBookClubTransaction(
  id: (json['id'] as num).toInt(),
  activityTypeId: (json['activityTypeId'] as num).toInt(),
  userBookClubId: (json['userBookClubId'] as num).toInt(),
  points: (json['points'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  orderItemId: (json['orderItemId'] as num?)?.toInt(),
  bookTransactionId: (json['bookTransactionId'] as num?)?.toInt(),
  orderItem: json['orderItem'],
  bookTransaction:
      json['bookTransaction'] == null
          ? null
          : BookTransaction.fromJson(
            json['bookTransaction'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$UserBookClubTransactionToJson(
  UserBookClubTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'activityTypeId': instance.activityTypeId,
  'userBookClubId': instance.userBookClubId,
  'points': instance.points,
  'createdAt': instance.createdAt.toIso8601String(),
  'orderItemId': instance.orderItemId,
  'bookTransactionId': instance.bookTransactionId,
  'orderItem': instance.orderItem,
  'bookTransaction': instance.bookTransaction,
};
