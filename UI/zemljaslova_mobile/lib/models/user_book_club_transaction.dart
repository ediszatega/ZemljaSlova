import 'package:json_annotation/json_annotation.dart';
import 'book_transaction.dart';

part 'user_book_club_transaction.g.dart';

@JsonSerializable()
class UserBookClubTransaction {
  final int id;
  final int activityTypeId;
  final int userBookClubId;
  final int points;
  final DateTime createdAt;
  final int? orderItemId;
  final int? bookTransactionId;
  final dynamic orderItem;
  final BookTransaction? bookTransaction;

  UserBookClubTransaction({
    required this.id,
    required this.activityTypeId,
    required this.userBookClubId,
    required this.points,
    required this.createdAt,
    this.orderItemId,
    this.bookTransactionId,
    this.orderItem,
    this.bookTransaction,
  });

  factory UserBookClubTransaction.fromJson(Map<String, dynamic> json) => _$UserBookClubTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$UserBookClubTransactionToJson(this);

  String get activityTypeName {
    switch (activityTypeId) {
      case 5:
        return 'Članarina';
      case 6:
        return 'Kupovina knjige';
      case 7:
        return 'Iznajmljivanje knjige';
      case 8:
        return 'Kupovina karte za događaj';
      case 9:
        return 'Kupovina vaučera';
      default:
        return 'Nepoznata aktivnost';
    }
  }
}
