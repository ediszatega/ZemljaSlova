import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discount.dart';
import '../providers/discount_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/search_input.dart';

class DiscountsOverview extends StatefulWidget {
  const DiscountsOverview({super.key});

  @override
  State<DiscountsOverview> createState() => _DiscountsOverviewState();
}

class _DiscountsOverviewState extends State<DiscountsOverview> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiscountProvider>(context, listen: false).fetchDiscounts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          const SidebarWidget(),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0, left: 80.0, right: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Pregled popusta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Toolbar
                  _buildToolbar(),
                  
                  const SizedBox(height: 24),
                  
                  // Discounts table
                  Expanded(
                    child: _buildDiscountsTable(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search field
        Expanded(
          child: SearchInput(
            label: 'Pretraži',
            hintText: 'Pretraži popuste po imenu ili kodu',
            controller: _searchController,
            borderColor: Colors.grey.shade300,
            onChanged: (value) => _applyFilters(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Filter button
        ZSButton(
          onPressed: () {
            // TODO: Implement filter functionality
          },
          text: 'Postavi filtere',
          label: 'Filtriraj',
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
        
        const SizedBox(width: 16),
        
        // Cleanup expired discounts button
        ZSButton(
          onPressed: () => _showCleanupDialog(),
          text: 'Ukloni istekle',
          backgroundColor: const Color(0xFFFFF3E0),
          foregroundColor: Colors.orange,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
        
        const SizedBox(width: 16),
        
        // Add discount button
        ZSButton(
          onPressed: () {
            // TODO: Navigate to add discount screen
          },
          text: 'Dodaj popust',
          backgroundColor: const Color(0xFFE5FFEE),
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
      ],
    );
  }

  Widget _buildDiscountsTable() {
    return Consumer<DiscountProvider>(
      builder: (context, discountProvider, child) {
        if (discountProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (discountProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Greška: ${discountProvider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ZSButton(
                  text: 'Pokušaj ponovo',
                  onPressed: () {
                    discountProvider.fetchDiscounts();
                  },
                ),
              ],
            ),
          );
        }

        final discounts = _getFilteredDiscounts(discountProvider.discounts);

        if (discounts.isEmpty) {
          return const Center(
            child: Text(
              'Nema popusta za prikaz',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(60),   // Redni broj
                1: FlexColumnWidth(2),     // Ime
                2: FixedColumnWidth(90),   // Procenat
                3: FixedColumnWidth(100),  // Tip
                4: FixedColumnWidth(100),  // Status
                5: FixedColumnWidth(120),  // Kod
                6: FixedColumnWidth(100),   // Korištenje
                7: FixedColumnWidth(120),  // Početak
                8: FixedColumnWidth(110),  // Kraj
                9: FixedColumnWidth(100),  // Akcije
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  children: [
                    _buildTableHeader('Br.'),
                    _buildTableHeader('Ime'),
                    _buildTableHeader('Procenat'),
                    _buildTableHeader('Tip'),
                    _buildTableHeader('Status'),
                    _buildTableHeader('Kod'),
                    _buildTableHeader('Korištenje'),
                    _buildTableHeader('Početak'),
                    _buildTableHeader('Kraj'),
                    _buildTableHeader('Akcije'),
                  ],
                ),
                
                ...discounts.asMap().entries.map((entry) => _buildDiscountRow(entry.value, entry.key + 1)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  TableRow _buildDiscountRow(Discount discount, int orderNumber) {
    return TableRow(
      decoration: BoxDecoration(
        color: discount.isExpired ? Colors.red.shade50 : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      children: [
        _buildTableCell(orderNumber.toString()),
        _buildTableCell(discount.name),
        _buildTableCell('${discount.discountPercentage.toStringAsFixed(0)}%'),
        _buildTableCell(discount.scopeDisplay),
        _buildTableCell(
          discount.statusDisplay,
          color: discount.statusColor,
        ),
        _buildTableCell(discount.code ?? '-'),
        _buildTableCell(discount.usageDisplay),
        _buildTableCell(_formatDate(discount.startDate)),
        _buildTableCell(
          _formatDate(discount.endDate),
          color: discount.isExpired ? Colors.red : null,
        ),
        _buildActionsCell(discount),
      ],
    );
  }

  Widget _buildTableCell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionsCell(Discount discount) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _showDeleteDialog(discount),
            icon: const Icon(Icons.delete, size: 18),
            tooltip: 'Obriši',
            color: Colors.red,
          ),
          
          IconButton(
            onPressed: () => _showDiscountDetails(discount),
            icon: const Icon(Icons.info, size: 18),
            tooltip: 'Detalji',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    final discountProvider = Provider.of<DiscountProvider>(context, listen: false);
    
    discountProvider.fetchDiscounts(
      code: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  List<Discount> _getFilteredDiscounts(List<Discount> discounts) {
    if (_searchController.text.isEmpty) {
      return discounts;
    }
    
    final searchTerm = _searchController.text.toLowerCase();
    return discounts.where((discount) =>
      discount.name.toLowerCase().contains(searchTerm) ||
      (discount.code?.toLowerCase().contains(searchTerm) ?? false)
    ).toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}.${date.month}.${date.year}';
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uklanjanje isteklih popusta'),
          content: const Text(
            'Da li ste sigurni da želite ukloniti sve istekle popuste sa knjiga?\n\n'
            'Ova akcija će ukloniti popuste sa knjiga, ali neće obrisati same popuste iz sistema.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final removedCount = await Provider.of<DiscountProvider>(context, listen: false)
                    .cleanupExpiredDiscounts();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Uklonjeno je $removedCount isteklih popusta sa knjiga'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Ukloni'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(Discount discount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda brisanja'),
          content: Text(
            'Da li ste sigurni da želite obrisati popust "${discount.name}"?\n\n'
            'Ova akcija se ne može poništiti.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await Provider.of<DiscountProvider>(context, listen: false)
                    .deleteDiscount(discount.id);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Popust je uspješno obrisan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Greška pri brisanju popusta'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );
  }

  void _showDiscountDetails(Discount discount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalji popusta "${discount.name}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID:', discount.id.toString()),
              _buildDetailRow('Ime:', discount.name),
              _buildDetailRow('Procenat:', '${discount.discountPercentage}%'),
              _buildDetailRow('Tip:', discount.scopeDisplay),
              _buildDetailRow('Status:', discount.statusDisplay),
              _buildDetailRow('Kod:', discount.code ?? 'Nema'),
              _buildDetailRow('Korištenje:', discount.usageDisplay),
              _buildDetailRow('Opis:', discount.description ?? 'Nema'),
              _buildDetailRow('Početak:', _formatDate(discount.startDate)),
              _buildDetailRow('Kraj:', _formatDate(discount.endDate)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zatvori'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 