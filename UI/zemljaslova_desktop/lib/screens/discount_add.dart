import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/discount_provider.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_date_picker.dart';

class DiscountAddScreen extends StatefulWidget {
  const DiscountAddScreen({super.key});

  @override
  State<DiscountAddScreen> createState() => _DiscountAddScreenState();
}

class _DiscountAddScreenState extends State<DiscountAddScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _maxUsageController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _bookSearchController = TextEditingController();
  
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int selectedScope = 2; // Default to Order scope
  bool isActive = true;
  List<int> selectedBookIds = [];
  String bookSearchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      await bookProvider.fetchBooks(refresh: true);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _percentageController.dispose();
    _codeController.dispose();
    _maxUsageController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _bookSearchController.dispose();
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Dodaj novi popust',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Form
                    _buildForm(),
                    
                    const SizedBox(height: 40),
                    
                    // Action buttons
                    _buildActionButtons(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          SizedBox(
            width: 600,
            child: ZSInput(
              label: 'Ime popusta *',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ime popusta je obavezno';
                }
                return null;
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Description field
          SizedBox(
            width: 600,
            child: ZSInput(
              label: 'Opis',
              controller: _descriptionController,
              maxLines: 3,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Percentage field
          SizedBox(
            width: 600,
            child: ZSInput(
              label: 'Procenat popusta (%) *',
              controller: _percentageController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Procenat popusta je obavezan';
                }
                final percentage = double.tryParse(value);
                if (percentage == null || percentage <= 0 || percentage > 100) {
                  return 'Procenat mora biti između 0.01% i 100%';
                }
                return null;
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Code field
          SizedBox(
            width: 600,
            child: ZSInput(
              label: 'Kod popusta',
              controller: _codeController,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Max Usage field
          SizedBox(
            width: 600,
            child: ZSInput(
              label: 'Maksimalno korištenja',
              controller: _maxUsageController,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final maxUsage = int.tryParse(value);
                  if (maxUsage == null || maxUsage <= 0) {
                    return 'Maksimalno korištenja mora biti pozitivan broj';
                  }
                }
                return null;
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Scope dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tip popusta *',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Container(
                width: 600,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedScope,
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
                  validator: (value) {
                    if (value == null) {
                      return 'Molimo odaberite tip popusta';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  hint: const Text('Odaberite tip popusta...'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Start date field
          SizedBox(
            width: 600,
            child: ZSDatePicker(
              label: 'Datum početka *',
              controller: _startDateController,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // Allow 2 years in future
              validator: (value) {
                if (selectedStartDate == null) {
                  return 'Datum početka je obavezan';
                }
                if (selectedStartDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                  return 'Datum početka ne može biti u prošlosti';
                }
                return null;
              },
              onDateSelected: (date) {
                setState(() {
                  selectedStartDate = date;
                  _startDateController.text = _formatDate(date);
                });
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // End date field
          SizedBox(
            width: 600,
            child: ZSDatePicker(
              label: 'Datum kraja *',
              controller: _endDateController,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // Allow 2 years in future
              validator: (value) {
                if (selectedEndDate == null) {
                  return 'Datum kraja je obavezan';
                }
                if (selectedStartDate != null && selectedEndDate!.isBefore(selectedStartDate!)) {
                  return 'Datum kraja mora biti nakon datuma početka';
                }
                return null;
              },
              onDateSelected: (date) {
                setState(() {
                  selectedEndDate = date;
                  _endDateController.text = _formatDate(date);
                });
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Active checkbox
          SizedBox(
            width: 600,
            child: CheckboxListTile(
              title: const Text('Aktivan'),
              value: isActive,
              onChanged: (bool? value) {
                setState(() {
                  isActive = value ?? true;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Book selection for book-specific discounts
          if (selectedScope == 1) ...[
            const Text(
              'Odaberite knjige za popust:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Selected books as tags
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Consumer<BookProvider>(
                builder: (context, bookProvider, child) {
                  final selectedBooks = bookProvider.books.where((book) => 
                    selectedBookIds.contains(book.id) && book.bookPurpose == BookPurpose.sell
                  ).toList();
                  
                  if (selectedBooks.isNotEmpty) {
                    return Container(
                      width: 600,
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
                      width: 600,
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
            SizedBox(
              width: 600,
              child: TextField(
                controller: _bookSearchController,
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
            ),
            const SizedBox(height: 8),
            
            // Filtered books list
            if (!_isLoading)
              Consumer<BookProvider>(
                builder: (context, bookProvider, child) {
                  final books = bookProvider.books.where((book) {
                    final matchesSearch = bookSearchQuery.isEmpty || 
                        book.title.toLowerCase().contains(bookSearchQuery);
                    final notSelected = !selectedBookIds.contains(book.id);
                    final isForSale = book.bookPurpose == BookPurpose.sell;
                    return matchesSearch && notSelected && isForSale;
                  }).toList();
                  
                  if (books.isEmpty) {
                    return Container(
                      width: 600,
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
                    width: 600,
                    height: 200,
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
                            book.price != null 
                              ? '${book.price!.toStringAsFixed(2)} KM'
                              : 'Knjiga za iznajmljivanje',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () {
                              setState(() {
                                selectedBookIds.add(book.id);
                                _bookSearchController.clear();
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ZSButton(
          text: 'Spremi',
          backgroundColor: Colors.green.shade50,
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 250,
          onPressed: _addDiscount,
        ),
        
        const SizedBox(width: 20),
        
        ZSButton(
          text: 'Odustani',
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.grey.shade700,
          borderColor: Colors.grey.shade300,
          width: 250,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  void _addDiscount() {
    if (_formKey.currentState!.validate()) {
      // Additional validation for book-specific discounts
      if (selectedScope == 1 && selectedBookIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Morate odabrati najmanje jednu knjigu za popust na knjige'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final discountProvider = Provider.of<DiscountProvider>(context, listen: false);
      
      final maxUsage = _maxUsageController.text.trim().isNotEmpty 
          ? int.tryParse(_maxUsageController.text) 
          : null;
      
      discountProvider.createDiscount(
        discountPercentage: double.parse(_percentageController.text),
        startDate: selectedStartDate!,
        endDate: selectedEndDate!,
        code: _codeController.text.trim().isNotEmpty ? _codeController.text.trim() : null,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        scope: selectedScope,
        maxUsage: maxUsage,
        isActive: isActive,
        bookIds: selectedScope == 1 ? selectedBookIds : null,
      ).then((success) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Popust je uspješno dodan!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to discounts list
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/discounts',
            (route) => false,
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška prilikom dodavanja popusta: ${discountProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
} 