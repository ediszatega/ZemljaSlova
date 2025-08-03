import 'package:flutter/material.dart';
import '../models/ticket_type_transaction.dart';
import '../services/inventory_service.dart';
import '../services/api_service.dart';
import '../widgets/inventory_screen.dart';

class TicketInventoryScreen extends StatelessWidget {
  final int ticketTypeId;
  final String ticketTypeName;
  
  const TicketInventoryScreen({
    super.key,
    required this.ticketTypeId,
    required this.ticketTypeName,
  });

  @override
  Widget build(BuildContext context) {
    return InventoryScreen<TicketTypeTransaction>(
      itemId: ticketTypeId,
      itemTitle: ticketTypeName,
      inventoryService: InventoryService<TicketTypeTransaction>(
        ApiService(),
        'TicketTypeTransaction/ticket-type',
        TicketTypeTransaction.fromJson,
      ),
      itemLabel: 'ulaznica',
      sellButtonText: 'Prodaj ulaznice',
      sellSuccessMessage: 'Ulaznice uspješno prodane',
      insufficientStockMessage: 'Nema dovoljno ulaznica na stanju',
    );
  }
} 