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
  final int crossAxisCount;

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
    this.crossAxisCount = 4,
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
            return Column(
              children: [
                Expanded(child: emptyStateWidget!),
                const SizedBox(height: 20),
                _buildPaginationControls(),
              ],
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: Center(
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
                ),
              ),
              const SizedBox(height: 20),
              _buildPaginationControls(),
            ],
          );
        }

        // Data display
        return Column(
          children: [
            // Main content
            Expanded(
              child: gridBuilder != null
                  ? gridBuilder!(context, provider.items)
                  : useGridLayout
                      ? _buildDefaultGrid(context)
                      : _buildDefaultList(context),
            ),
            
            const SizedBox(height: 20),
            
            // Pagination controls
            _buildPaginationControls(),
          ],
        );
      },
    );
  }

  Widget _buildDefaultGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 40,
        mainAxisSpacing: 40,
        childAspectRatio: 0.65,
      ),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        return itemBuilder!(context, provider.items[index], index);
      },
    );
  }

  Widget _buildDefaultList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: provider.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return itemBuilder!(context, provider.items[index], index);
      },
    );
  }

  Widget _buildPaginationControls() {
    return PaginationControlsWidget(
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
    );
  }
} 