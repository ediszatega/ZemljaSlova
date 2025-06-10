import 'package:json_annotation/json_annotation.dart';

part 'author.g.dart';

@JsonSerializable()
class Author {
  final int id;
  final String firstName;
  final String lastName;
  final String? dateOfBirth;
  final String? genre;
  final String? biography;

  Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.genre,
    this.biography,
  });

  String get fullName => '$firstName $lastName';

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorToJson(this);
} 