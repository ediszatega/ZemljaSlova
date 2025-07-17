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
    this.pageSizeOptions = const [5, 10, 20, 50],
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Item count info
          Text(
            'Prikazano $currentItemCount od $totalCount $itemName',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Center - Page size selector
          Row(
            children: [
              Text(
                '${_capitalizeFirst(itemName)} po stranici: ',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<int>(
                  value: currentPageSize,
                  underline: const SizedBox(),
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
              ),
            ],
          ),
          
          // Right side - Load more button or loading indicator
          if (isLoadingMore)
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Učitavanje...'),
              ],
            )
          else if (hasMoreData)
            ElevatedButton(
              onPressed: onLoadMore,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(loadMoreText ?? 'Učitaj više ${itemName.toLowerCase()}'),
            )
          else
            const SizedBox.shrink(), // Empty space when no more data
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
} 