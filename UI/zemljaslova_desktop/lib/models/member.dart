import 'package:json_annotation/json_annotation.dart';

part 'member.g.dart';

@JsonSerializable()
class Member {
  final int id;
  final int userId;
  final DateTime dateOfBirth;
  final DateTime joinedAt;
  final String firstName;
  final String lastName;
  final String email;
  final String? gender;
  final bool isActive;
  final String? profileImageUrl;

  Member({
    required this.id,
    required this.userId,
    required this.dateOfBirth,
    required this.joinedAt,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.gender,
    required this.isActive,
    this.profileImageUrl,
  });

  String get fullName => '$firstName $lastName';

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);
} 