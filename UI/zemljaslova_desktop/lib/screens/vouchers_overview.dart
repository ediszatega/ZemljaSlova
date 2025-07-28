import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/voucher.dart';
import '../providers/voucher_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/empty_state.dart';
import '../widgets/permission_guard.dart';
import '../widgets/filter_dialog.dart';
import '../utils/filter_configurations.dart';
import '../models/voucher_filters.dart';
import 'voucher_add.dart';

class VouchersOverview extends StatefulWidget {
  const VouchersOverview({super.key});

  @override
  State<VouchersOverview> createState() => _VouchersOverviewState();
}

class _VouchersOverviewState extends State<VouchersOverview> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VoucherProvider>(context, listen: false).fetchVouchers();
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
                    'Pregled vaučera',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Toolbar
                  _buildToolbar(),
                  
                  const SizedBox(height: 24),
                  
                  // Vouchers table
                  Expanded(
                    child: _buildVouchersTable(),
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
            hintText: 'Pretraži vaučere po kodu',
            controller: _searchController,
            borderColor: Colors.grey.shade300,
            onChanged: (value) => _applyFilters(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Filter button
        Consumer<VoucherProvider>(
          builder: (context, voucherProvider, child) {
            final hasActiveFilters = voucherProvider.filters.hasActiveFilters;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ZSButton(
                  onPressed: () {
                    _showFiltersDialog();
                  },
                  text: hasActiveFilters ? 'Filteri aktivni (${_getActiveFilterCount(voucherProvider.filters)})' : 'Postavi filtre',
                  label: 'Filtriraj',
                  backgroundColor: hasActiveFilters ? const Color(0xFFE3F2FD) : Colors.white,
                  foregroundColor: hasActiveFilters ? Colors.blue : Colors.black,
                  borderColor: hasActiveFilters ? Colors.blue : Colors.grey.shade300,
                  width: 180,
                ),
                if (hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 40,
                    child: IconButton(
                      onPressed: () {
                        voucherProvider.clearFilters();
                      },
                      icon: const Icon(Icons.clear, color: Colors.red),
                      tooltip: 'Očisti filtre',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        
        const SizedBox(width: 16),
        
        // Add voucher button
        ZSButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VoucherAddScreen(),
              ),
            );
          },
          text: 'Dodaj vaučer',
          backgroundColor: const Color(0xFFE5FFEE),
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
      ],
    );
  }

  void _showFiltersDialog() {
    final voucherProvider = Provider.of<VoucherProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        title: 'Filtriraj vaučere',
        fields: FilterConfigurations.getVoucherFilters(context),
        initialValues: voucherProvider.filters.toMap(),
        onApplyFilters: (Map<String, dynamic> values) {
          final filters = VoucherFilters.fromMap(values);
          voucherProvider.setFilters(filters);
        },
        onClearFilters: () {
          voucherProvider.clearFilters();
        },
      ),
    );
  }

  int _getActiveFilterCount(VoucherFilters filters) {
    int count = 0;
    if (filters.minValue != null) count++;
    if (filters.maxValue != null) count++;
    if (filters.voucherType != null) count++;
    if (filters.isUsed != null) count++;
    if (filters.expirationDateFrom != null) count++;
    if (filters.expirationDateTo != null) count++;
    return count;
  }

  void _applyFilters() {
    final voucherProvider = Provider.of<VoucherProvider>(context, listen: false);
    
    voucherProvider.fetchVouchers(
      code: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  Widget _buildVouchersTable() {
    return Consumer<VoucherProvider>(
      builder: (context, voucherProvider, child) {
        if (voucherProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (voucherProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Greška: ${voucherProvider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ZSButton(
                  text: 'Pokušaj ponovo',
                  onPressed: () {
                    voucherProvider.fetchVouchers();
                  },
                ),
              ],
            ),
          );
        }

        final vouchers = _getFilteredVouchers(voucherProvider.vouchers);

        if (vouchers.isEmpty) {
          return const EmptyState(
            icon: Icons.card_giftcard,
            title: 'Nema vaučera za prikaz',
            description: 'Trenutno nema izdatih vaučera.\nKreirajte vaučere za promocije.',
          );
        }

        return Column(
          children: [
            // Table
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(80),   // Redni broj
                      1: FixedColumnWidth(120),  // Kod
                      2: FixedColumnWidth(100),  // Vrijednost
                      3: FixedColumnWidth(100),  // Status
                      4: FixedColumnWidth(120),  // Tip
                      5: FlexColumnWidth(2),     // Kupac
                      6: FixedColumnWidth(120),  // Datum kreiranja
                      7: FixedColumnWidth(120),  // Datum isteka
                      8: FixedColumnWidth(100),  // Akcije
                    },
                    children: [
                      // Header
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                        ),
                        children: [
                          _buildTableHeader('Br.'),
                          _buildTableHeader('Kod'),
                          _buildTableHeader('Vrijednost'),
                          _buildTableHeader('Status'),
                          _buildTableHeader('Tip'),
                          _buildTableHeader('Kupac'),
                          _buildTableHeader('Kreiran'),
                          _buildTableHeader('Ističe'),
                          _buildTableHeader('Akcije'),
                        ],
                      ),
                      
                      ...vouchers.asMap().entries.map((entry) => _buildVoucherRow(
                        entry.value, 
                        (voucherProvider.currentPage * voucherProvider.pageSize) + entry.key + 1
                      )),
                    ],
                  ),
                ),
              ),
            ),
            
            // Pagination controls
            if (voucherProvider.shouldShowPagination)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Total count
                    Text(
                      'Ukupno ${voucherProvider.totalCount} vaučera',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    // Page info and navigation
                    Row(
                      children: [
                        Text(
                          'Stranica ${voucherProvider.currentPage + 1} od ${voucherProvider.totalPages}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        
                        // Previous button
                        IconButton(
                          onPressed: voucherProvider.hasPreviousPage && !voucherProvider.isLoading
                              ? voucherProvider.previousPage
                              : null,
                          icon: const Icon(Icons.chevron_left),
                          tooltip: 'Prethodna stranica',
                        ),
                        
                        // Next button
                        IconButton(
                          onPressed: voucherProvider.hasNextPage && !voucherProvider.isLoading
                              ? voucherProvider.nextPage
                              : null,
                          icon: const Icon(Icons.chevron_right),
                          tooltip: 'Sljedeća stranica',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
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

  TableRow _buildVoucherRow(Voucher voucher, int orderNumber) {
    final isExpired = voucher.expirationDate.isBefore(DateTime.now());
    
    return TableRow(
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.shade50 : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      children: [
        _buildTableCell(orderNumber.toString()),
        _buildTableCell(voucher.code),
        _buildTableCell('${voucher.value.toStringAsFixed(2)} KM'),
        _buildTableCell(
          voucher.statusDisplay,
          color: voucher.isUsed ? Colors.red : Colors.green,
        ),
        _buildTableCell(
          voucher.typeDisplay,
          color: voucher.isPurchasedByMember ? Colors.blue : Colors.orange,
        ),
        _buildTableCell(voucher.purchaserDisplay),
        _buildTableCell(_formatDate(voucher.purchasedAt)),
        _buildTableCell(
          _formatDate(voucher.expirationDate),
          color: isExpired ? Colors.red : null,
        ),
        _buildActionsCell(voucher),
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

  Widget _buildActionsCell(Voucher voucher) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (voucher.isPromotional && !voucher.isUsed)
            IconButton(
              onPressed: () => _showDeleteDialog(voucher),
              icon: const Icon(Icons.delete, size: 18),
              tooltip: 'Obriši',
              color: Colors.red,
            ),
          
          IconButton(
            onPressed: () => _showVoucherDetails(voucher),
            icon: const Icon(Icons.info, size: 18),
            tooltip: 'Detalji',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  List<Voucher> _getFilteredVouchers(List<Voucher> vouchers) {
    return vouchers;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}.${date.month}.${date.year}';
  }

  void _showDeleteDialog(Voucher voucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda brisanja'),
          content: Text(
            'Da li ste sigurni da želite obrisati vaučer ${voucher.code}?\n\n'
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
                final success = await Provider.of<VoucherProvider>(context, listen: false)
                    .deleteVoucher(voucher.id);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vaučer je uspješno obrisan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Greška pri brisanju vaučera'),
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

  void _showVoucherDetails(Voucher voucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalji vaučera ${voucher.code}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID:', voucher.id.toString()),
              _buildDetailRow('Kod:', voucher.code),
              _buildDetailRow('Vrijednost:', '${voucher.value.toStringAsFixed(2)} KM'),
              _buildDetailRow('Status:', voucher.statusDisplay),
              _buildDetailRow('Tip:', voucher.typeDisplay),
              _buildDetailRow('Kupac:', voucher.purchaserDisplay),
              _buildDetailRow('Kreiran:', _formatDate(voucher.purchasedAt)),
              _buildDetailRow('Ističe:', _formatDate(voucher.expirationDate)),
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