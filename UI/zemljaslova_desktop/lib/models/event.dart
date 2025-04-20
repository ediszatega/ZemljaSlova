import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  final int id;
  final String title;
  final String organizer;
  final String date;
  final double price;
  final String? imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.organizer,
    required this.date,
    required this.price,
    this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
} 