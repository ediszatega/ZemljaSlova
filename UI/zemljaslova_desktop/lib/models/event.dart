import 'package:json_annotation/json_annotation.dart';
import 'ticket_type.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  final int id;
  final String title;
  final String description;
  final String? location;
  final DateTime startAt;
  final DateTime endAt;
  final String? organizer;
  final String? lecturers;
  final String? coverImageUrl;
  final int? maxNumberOfPeople;
  final List<TicketType>? ticketTypes;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    required this.startAt,
    required this.endAt,
    this.organizer,
    this.lecturers,
    this.coverImageUrl,
    this.maxNumberOfPeople,
    this.ticketTypes,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
} 