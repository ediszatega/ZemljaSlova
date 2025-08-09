import 'package:json_annotation/json_annotation.dart';
import '../widgets/inventory_screen.dart';

part 'ticket_type_transaction.g.dart';

@JsonSerializable()
class TicketTypeTransaction implements InventoryTransaction {
  final int? id;
  @override
  final int activityTypeId;
  final int ticketTypeId;
  @override
  final int quantity;
  @override
  final DateTime createdAt;
  final int userId;
  @override
  final String? data;

  TicketTypeTransaction({
    this.id,
    required this.activityTypeId,
    required this.ticketTypeId,
    required this.quantity,
    required this.createdAt,
    required this.userId,
    this.data,
  });

  factory TicketTypeTransaction.fromJson(Map<String, dynamic> json) => _$TicketTypeTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TicketTypeTransactionToJson(this);
}

enum ActivityType {
  stock(1),
  sold(2),
  remove(3),
  rent(4);

  const ActivityType(this.value);
  final int value;

  static ActivityType fromValue(int value) {
    return ActivityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ActivityType.stock,
    );
  }
} 