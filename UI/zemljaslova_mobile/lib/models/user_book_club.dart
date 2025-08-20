import 'package:json_annotation/json_annotation.dart';
import 'member.dart';
import 'user_book_club_transaction.dart';

part 'user_book_club.g.dart';

@JsonSerializable()
class UserBookClub {
  final int id;
  final int year;
  final int memberId;
  final Member? member;
  final List<UserBookClubTransaction>? userBookClubTransactions;

  UserBookClub({
    required this.id,
    required this.year,
    required this.memberId,
    this.member,
    this.userBookClubTransactions,
  });

  factory UserBookClub.fromJson(Map<String, dynamic> json) => _$UserBookClubFromJson(json);
  Map<String, dynamic> toJson() => _$UserBookClubToJson(this);
}
