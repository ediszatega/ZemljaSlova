import 'package:json_annotation/json_annotation.dart';
import 'book.dart';
import 'member.dart';

part 'recommendation.g.dart';

@JsonSerializable()
class Recommendation {
  final int id;
  final int memberId;
  final int bookId;
  final Book? book;
  final Member? member;

  Recommendation({
    required this.id,
    required this.memberId,
    required this.bookId,
    this.book,
    this.member,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) => 
      _$RecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationToJson(this);
}
