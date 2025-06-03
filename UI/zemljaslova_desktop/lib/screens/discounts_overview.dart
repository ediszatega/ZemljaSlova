import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discount.dart';
import '../providers/discount_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/search_input.dart';
import '../providers/book_provider.dart';

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
                5: FixedColumnWidth(100),  // Korištenje
                6: FixedColumnWidth(120),  // Početak
                7: FixedColumnWidth(110),  // Kraj
                8: FixedColumnWidth(140),  // Akcije (wider)
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
            onPressed: () => _editDiscount(discount),
            icon: const Icon(Icons.edit, size: 18),
            tooltip: 'Uredi',
            color: Colors.blue,
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

  void _editDiscount(Discount discount) {
    // Create controllers and initialize with current values
    final nameController = TextEditingController(text: discount.name);
    final descriptionController = TextEditingController(text: discount.description ?? '');
    final percentageController = TextEditingController(text: discount.discountPercentage.toString());
    final codeController = TextEditingController(text: discount.code ?? '');
    final maxUsageController = TextEditingController(text: discount.maxUsage?.toString() ?? '');
    final startDateController = TextEditingController(text: _formatDate(discount.startDate));
    final endDateController = TextEditingController(text: _formatDate(discount.endDate));
    final bookSearchController = TextEditingController();
    
    DateTime selectedStartDate = discount.startDate;
    DateTime selectedEndDate = discount.endDate;
    int selectedScope = discount.scope;
    bool isActive = discount.isActive;
    List<int> selectedBookIds = [];
    String bookSearchQuery = '';
    
    // Load books for book-specific discounts
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final discountService = Provider.of<DiscountProvider>(context, listen: false);
    
    if (discount.scope == 1) {
      // Get books with this discount
      discountService.getBooksWithDiscount(discount.id).then((books) {
        selectedBookIds = books.map((book) => book['id'] as int).toList();
      });
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Uredi popust - ${discount.name}'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name field
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Ime popusta',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Description field
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Opis (opciono)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Percentage field
                      TextField(
                        controller: percentageController,
                        decoration: const InputDecoration(
                          labelText: 'Procenat popusta',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      
                      // Code field
                      TextField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          labelText: 'Kod popusta (opciono)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Max Usage field
                      TextField(
                        controller: maxUsageController,
                        decoration: const InputDecoration(
                          labelText: 'Maksimalno korištenja (opciono)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      
                      // Scope dropdown
                      DropdownButtonFormField<int>(
                        value: selectedScope,
                        decoration: const InputDecoration(
                          labelText: 'Tip popusta',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Knjiga')),
                          DropdownMenuItem(value: 2, child: Text('Narudžba')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedScope = value;
                              if (value == 2) {
                                selectedBookIds.clear(); // Clear book selection if changing to order scope
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Start date field
                      TextField(
                        controller: startDateController,
                        decoration: const InputDecoration(
                          labelText: 'Datum početka',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedStartDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (date != null) {
                            setState(() {
                              selectedStartDate = date;
                              startDateController.text = _formatDate(date);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // End date field
                      TextField(
                        controller: endDateController,
                        decoration: const InputDecoration(
                          labelText: 'Datum kraja',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedEndDate,
                            firstDate: selectedStartDate,
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (date != null) {
                            setState(() {
                              selectedEndDate = date;
                              endDateController.text = _formatDate(date);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Active checkbox
                      CheckboxListTile(
                        title: const Text('Aktivan'),
                        value: isActive,
                        onChanged: (bool? value) {
                          setState(() {
                            isActive = value ?? true;
                          });
                        },
                      ),
                      
                      // Book selection for book-specific discounts
                      if (selectedScope == 1) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Odaberite knjige za popust:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        
                        // Selected books tags
                        Consumer<BookProvider>(
                          builder: (context, bookProvider, child) {
                            final selectedBooks = bookProvider.books.where((book) => selectedBookIds.contains(book.id)).toList();
                            
                            if (selectedBooks.isNotEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedBooks.map((book) {
                                    return Chip(
                                      label: Text(
                                        book.title,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      deleteIcon: const Icon(Icons.close, size: 18),
                                      onDeleted: () {
                                        setState(() {
                                          selectedBookIds.remove(book.id);
                                        });
                                      },
                                      backgroundColor: Colors.blue.shade50,
                                      side: BorderSide(color: Colors.blue.shade200),
                                    );
                                  }).toList(),
                                ),
                              );
                            } else {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Nijedna knjiga nije odabrana',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Search input for books
                        TextField(
                          controller: bookSearchController,
                          decoration: const InputDecoration(
                            labelText: 'Pretražite knjige',
                            hintText: 'Unesite naziv knjige...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              bookSearchQuery = value.toLowerCase();
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Filtered books list
                        Consumer<BookProvider>(
                          builder: (context, bookProvider, child) {
                            if (bookProvider.isLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            
                            final books = bookProvider.books.where((book) {
                              final matchesSearch = bookSearchQuery.isEmpty || 
                                  book.title.toLowerCase().contains(bookSearchQuery);
                              final notSelected = !selectedBookIds.contains(book.id);
                              return matchesSearch && notSelected;
                            }).toList();
                            
                            if (books.isEmpty) {
                              return Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    bookSearchQuery.isEmpty 
                                        ? 'Sve knjige su već odabrane'
                                        : 'Nema knjiga koje odgovaraju pretraži',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            return Container(
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListView.builder(
                                itemCount: books.length,
                                itemBuilder: (context, index) {
                                  final book = books[index];
                                  
                                  return ListTile(
                                    title: Text(
                                      book.title,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      '${book.price.toStringAsFixed(2)} KM',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.add, color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          selectedBookIds.add(book.id);
                                          bookSearchController.clear();
                                          bookSearchQuery = '';
                                        });
                                      },
                                    ),
                                    dense: true,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Otkaži'),
                ),
                TextButton(
                  onPressed: () async {
                    // Validate input
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ime popusta je obavezno'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    final percentage = double.tryParse(percentageController.text);
                    if (percentage == null || percentage <= 0 || percentage > 100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Procenat popusta mora biti između 0.01% i 100%'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    if (selectedStartDate.isAfter(selectedEndDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Datum početka mora biti prije datuma kraja'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    if (selectedScope == 1 && selectedBookIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Morate odabrati najmanje jednu knjigu za popust na knjige'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    Navigator.of(context).pop();
                    
                    final maxUsage = maxUsageController.text.trim().isNotEmpty 
                        ? int.tryParse(maxUsageController.text) 
                        : null;
                    
                    final success = await Provider.of<DiscountProvider>(context, listen: false)
                        .updateDiscount(
                      id: discount.id,
                      discountPercentage: percentage,
                      startDate: selectedStartDate,
                      endDate: selectedEndDate,
                      code: codeController.text.trim().isNotEmpty ? codeController.text.trim() : null,
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim().isNotEmpty ? descriptionController.text.trim() : null,
                      scope: selectedScope,
                      maxUsage: maxUsage,
                      isActive: isActive,
                      bookIds: selectedScope == 1 ? selectedBookIds : null,
                    );
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Popust je uspješno ažuriran'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Greška pri ažuriranju popusta'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Sačuvaj'),
                ),
              ],
            );
          },
        );
      },
    );
    
    // Load books when dialog opens
    bookProvider.fetchBooks();
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
              _buildDetailRow('Ime:', discount.name),
              _buildDetailRow('Opis:', discount.description ?? 'Nema'),
              _buildDetailRow('Procenat:', '${discount.discountPercentage}%'),
              _buildDetailRow('Tip:', discount.scopeDisplay),
              _buildDetailRow('Status:', discount.statusDisplay),
              _buildDetailRow('Kod:', discount.code ?? 'Nema'),
              _buildDetailRow('Korištenje:', discount.usageDisplay),
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