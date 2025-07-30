import 'package:flutter/material.dart';
import '../models/book_filters.dart';
import '../models/author.dart';
import '../providers/author_provider.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/zs_input.dart';
import 'package:provider/provider.dart';

class BookFilterDialog extends StatefulWidget {
  final BookFilters initialFilters;
  final Function(BookFilters) onApply;

  const BookFilterDialog({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<BookFilterDialog> createState() => _BookFilterDialogState();
}

class _BookFilterDialogState extends State<BookFilterDialog> {
  late BookFilters _filters;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  Author? _selectedAuthor;
  bool? _isAvailable;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _minPriceController.text = _filters.minPrice?.toString() ?? '';
    _maxPriceController.text = _filters.maxPrice?.toString() ?? '';
    _isAvailable = _filters.isAvailable;
    
    // Load authors when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAuthors();
    });
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _loadAuthors() async {
    final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
    await authorProvider.fetchAuthors();
    
    // Set selected author if there's an existing filter
    if (_filters.authorId != null) {
      final authors = authorProvider.authors;
      if (authors.isNotEmpty) {
        _selectedAuthor = authors.firstWhere(
          (author) => author.id == _filters.authorId,
          orElse: () => authors.first,
        );
      }
    }
  }

  void _applyFilters() {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);
    
    final newFilters = BookFilters(
      minPrice: minPrice,
      maxPrice: maxPrice,
      authorId: _selectedAuthor?.id,
      isAvailable: _isAvailable,
    );
    
    widget.onApply(newFilters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _filters = const BookFilters();
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedAuthor = null;
      _isAvailable = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Filtriraj knjige',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price range
                    const Text(
                      'Cijena',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ZSInput(
                            controller: _minPriceController,
                            label: 'Min cijena',
                            hintText: '0.00',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ZSInput(
                            controller: _maxPriceController,
                            label: 'Max cijena',
                            hintText: '1000.00',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Author filter
                    const Text(
                      'Autor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer<AuthorProvider>(
                      builder: (context, authorProvider, child) {
                        return ZSDropdown<Author?>(
                          label: 'Odaberi autora',
                          value: _selectedAuthor,
                          items: [
                            const DropdownMenuItem<Author?>(
                              value: null,
                              child: Text('Svi autori'),
                            ),
                            ...authorProvider.authors.map((author) => DropdownMenuItem<Author?>(
                              value: author,
                              child: Text('${author.firstName} ${author.lastName}'),
                            )),
                          ],
                          onChanged: (Author? author) {
                            setState(() {
                              _selectedAuthor = author;
                            });
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Availability filter
                    const Text(
                      'Dostupnost',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ZSDropdown<bool?>(
                      label: 'Status dostupnosti',
                      value: _isAvailable,
                      items: const [
                        DropdownMenuItem<bool?>(
                          value: null,
                          child: Text('Sve knjige'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: true,
                          child: Text('Dostupne'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: false,
                          child: Text('Nedostupne'),
                        ),
                      ],
                      onChanged: (bool? value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ZSButton(
                      onPressed: _clearFilters,
                      text: 'Očisti',
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ZSButton(
                      onPressed: _applyFilters,
                      text: 'Primijeni',
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 