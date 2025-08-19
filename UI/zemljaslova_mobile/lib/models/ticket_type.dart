import 'package:json_annotation/json_annotation.dart';

part 'ticket_type.g.dart';

@JsonSerializable()
class TicketType {
  final int id;
  final int eventId;
  final String name;
  final double price;
  final String description;
  final int? initialQuantity;
  final int? currentQuantity;

  TicketType({
    required this.id,
    required this.eventId,
    required this.name,
    required this.price,
    required this.description,
    this.initialQuantity,
    this.currentQuantity,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) => _$TicketTypeFromJson(json);

  Map<String, dynamic> toJson() => _$TicketTypeToJson(this);
} 