import 'package:flutter/material.dart';
import 'pagination_controls_widget.dart';

/// Interface that data providers should implement to work with PaginatedDataWidget
abstract class PaginatedDataProvider<T> extends ChangeNotifier {
  List<T> get items;
  bool get isInitialLoading;
  bool get isLoadingMore;
  String? get error;
  int get totalCount;
  bool get hasMoreData;
  int get pageSize;
  
  Future<void> loadMore();
  Future<void> refresh();
  void setPageSize(int newPageSize);
}

class PaginatedDataWidget<T> extends StatelessWidget {
  final PaginatedDataProvider<T> provider;
  final Widget Function(BuildContext context, T item, int index)? itemBuilder;
  final Widget Function(BuildContext context, List<T> items)? gridBuilder;
  final String itemName;
  final String? loadMoreText;
  final List<int> pageSizeOptions;
  final Widget? emptyStateWidget;
  final String? emptyStateMessage;
  final IconData? emptyStateIcon;
  final bool useGridLayout;

  const PaginatedDataWidget({
    super.key,
    required this.provider,
    this.itemBuilder,
    this.gridBuilder,
    this.itemName = 'stavki',
    this.loadMoreText,
    this.pageSizeOptions = const [5, 10, 20, 50],
    this.emptyStateWidget,
    this.emptyStateMessage,
    this.emptyStateIcon,
    this.useGridLayout = false,
  }) : assert(itemBuilder != null || gridBuilder != null, 
              'Either itemBuilder or gridBuilder must be provided');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider,
      builder: (context, child) {
        // Initial loading state
        if (provider.isInitialLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error state with no data
        if (provider.error != null && provider.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Greška pri učitavanju ${itemName.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.refresh();
                  },
                  child: const Text('Pokušaj ponovo'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (provider.items.isEmpty && !provider.isInitialLoading) {
          if (emptyStateWidget != null) {
            return emptyStateWidget!;
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  emptyStateIcon ?? Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyStateMessage ?? 'Nema dostupnih ${itemName.toLowerCase()}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Data display
        return Column(
          children: [
            // Main content
            if (gridBuilder != null)
              gridBuilder!(context, provider.items)
            else if (useGridLayout)
              _buildDefaultGrid(context)
            else
              _buildDefaultList(context),
            
            const SizedBox(height: 16),
            
            // Pagination controls
            PaginationControlsWidget(
              currentItemCount: provider.items.length,
              totalCount: provider.totalCount,
              hasMoreData: provider.hasMoreData,
              isLoadingMore: provider.isLoadingMore,
              onLoadMore: provider.loadMore,
              currentPageSize: provider.pageSize,
              onPageSizeChanged: provider.setPageSize,
              itemName: itemName,
              loadMoreText: loadMoreText,
              pageSizeOptions: pageSizeOptions,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate number of columns based on screen width
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.5,
          ),
          itemCount: provider.items.length,
          itemBuilder: (context, index) {
            return itemBuilder!(context, provider.items[index], index);
          },
        );
      },
    );
  }

  Widget _buildDefaultList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return itemBuilder!(context, provider.items[index], index);
      },
    );
  }
} 