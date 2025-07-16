import 'package:flutter/material.dart';

class PaginationControlsWidget extends StatelessWidget {
  final int currentItemCount;
  final int totalCount;
  final bool hasMoreData;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final int currentPageSize;
  final List<int> pageSizeOptions;
  final Function(int) onPageSizeChanged;
  final String itemName;
  final String? loadMoreText;

  const PaginationControlsWidget({
    super.key,
    required this.currentItemCount,
    required this.totalCount,
    required this.hasMoreData,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.currentPageSize,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [2, 5, 10, 20, 50],
    this.itemName = 'stavki',
    this.loadMoreText,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure current page size is in the options
    final availableOptions = List<int>.from(pageSizeOptions);
    if (!availableOptions.contains(currentPageSize)) {
      availableOptions.add(currentPageSize);
      availableOptions.sort();
    }

    return Column(
      children: [
        // Pagination info
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prikazano $currentItemCount od $totalCount $itemName',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Load more / Pagination controls
        if (hasMoreData || isLoadingMore)
          Column(
            children: [
              if (isLoadingMore)
                const CircularProgressIndicator()
              else if (hasMoreData)
                ElevatedButton(
                  onPressed: onLoadMore,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(loadMoreText ?? 'Učitaj više ${itemName.toLowerCase()}'),
                ),
              
              const SizedBox(height: 8),
              
              // Page size selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${_capitalizeFirst(itemName)} po stranici: '),
                  DropdownButton<int>(
                    value: currentPageSize,
                    items: availableOptions.map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text(size.toString()),
                      );
                    }).toList(),
                    onChanged: (newSize) {
                      if (newSize != null) {
                        onPageSizeChanged(newSize);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
} 