import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_filters.dart';
import '../models/author.dart';
import '../providers/author_provider.dart';
import 'zs_button.dart';
import 'zs_dropdown.dart';

class BookFiltersDialog extends StatefulWidget {
  final BookFilters initialFilters;
  final Function(BookFilters) onApplyFilters;

  const BookFiltersDialog({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
  });

  @override
  State<BookFiltersDialog> createState() => _BookFiltersDialogState();
}

class _BookFiltersDialogState extends State<BookFiltersDialog> {
  late BookFilters _filters;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  List<Author> _authors = [];
  bool _isLoadingAuthors = true;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _minPriceController.text = _filters.minPrice?.toString() ?? '';
    _maxPriceController.text = _filters.maxPrice?.toString() ?? '';
    
    // Defer loading authors until after the widget is built
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

  Future<void> _loadAuthors() async {
    try {
      final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
      await authorProvider.refresh();
      setState(() {
        _authors = authorProvider.authors;
        _isLoadingAuthors = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAuthors = false;
      });
    }
  }

  void _applyFilters() {
    // Parse price values
    double? minPrice;
    double? maxPrice;
    
    if (_minPriceController.text.isNotEmpty) {
      minPrice = double.tryParse(_minPriceController.text);
    }
    
    if (_maxPriceController.text.isNotEmpty) {
      maxPrice = double.tryParse(_maxPriceController.text);
    }

    final newFilters = _filters.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    widget.onApplyFilters(newFilters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _filters = BookFilters.empty;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  Author _getSelectedAuthor() {
    if (_filters.authorId == null) {
      return Author(id: 0, firstName: 'Svi autori', lastName: '');
    }
    
    try {
      return _authors.firstWhere(
        (author) => author.id == _filters.authorId,
        orElse: () => Author(id: 0, firstName: 'Svi autori', lastName: ''),
      );
    } catch (e) {
      return Author(id: 0, firstName: 'Svi autori', lastName: '');
    }
  }

  String _getAvailabilityValue() {
    if (_filters.isAvailable == null) {
      return 'Sve knjige';
    }
    return _filters.isAvailable! ? 'Dostupne' : 'Nedostupne';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtri za knjige',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Price range
            const Text(
              'Raspon cijene',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Minimalna cijena',
                      border: OutlineInputBorder(),
                      suffixText: 'KM',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Maksimalna cijena',
                      border: OutlineInputBorder(),
                      suffixText: 'KM',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Author filter
            const Text(
              'Autor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoadingAuthors)
              const Center(child: CircularProgressIndicator())
            else
              ZSDropdown<Author>(
                value: _getSelectedAuthor(),
                items: [
                  DropdownMenuItem<Author>(
                    value: Author(id: 0, firstName: 'Svi autori', lastName: ''),
                    child: const Text('Svi autori'),
                  ),
                  ..._authors.map((author) => DropdownMenuItem<Author>(
                    value: author,
                    child: Text('${author.firstName} ${author.lastName}'),
                  )),
                ],
                onChanged: (author) {
                  setState(() {
                    _filters = _filters.copyWith(
                      authorId: author?.id == 0 ? null : author?.id,
                    );
                  });
                },
                borderColor: Colors.grey.shade300,
              ),
            const SizedBox(height: 24),

            // Availability filter
            const Text(
              'Dostupnost',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ZSDropdown<String>(
              value: _getAvailabilityValue(),
              items: [
                const DropdownMenuItem<String>(
                  value: 'Sve knjige',
                  child: Text('Sve knjige'),
                ),
                const DropdownMenuItem<String>(
                  value: 'Dostupne',
                  child: Text('Dostupne'),
                ),
                const DropdownMenuItem<String>(
                  value: 'Nedostupne',
                  child: Text('Nedostupne'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(
                    isAvailable: value == 'Sve knjige' 
                        ? null 
                        : value == 'Dostupne' 
                            ? true 
                            : false,
                  );
                });
              },
              borderColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ZSButton(
                  onPressed: _clearFilters,
                  text: 'Očisti filtre',
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade700,
                  borderColor: Colors.grey.shade300,
                ),
                const SizedBox(width: 12),
                ZSButton(
                  onPressed: _applyFilters,
                  text: 'Primijeni filtre',
                  backgroundColor: const Color(0xFFE5FFEE),
                  foregroundColor: Colors.green,
                  borderColor: Colors.grey.shade300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 