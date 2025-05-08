import 'package:json_annotation/json_annotation.dart';

part 'ticket_type.g.dart';

@JsonSerializable()
class TicketType {
  final int? id;
  final int eventId;
  final double price;
  final String name;
  final String? description;

  TicketType({
    this.id,
    required this.eventId,
    required this.price,
    required this.name,
    this.description,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) => _$TicketTypeFromJson(json);

  Map<String, dynamic> toJson() => _$TicketTypeToJson(this);
} 