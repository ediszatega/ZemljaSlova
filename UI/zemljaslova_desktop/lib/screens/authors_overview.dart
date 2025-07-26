import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/author.dart';
import '../providers/author_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/empty_state.dart';
import '../widgets/pagination_controls_widget.dart';
import '../widgets/search_loading_indicator.dart';
import 'author_detail_overview.dart';
import 'author_add.dart';

class AuthorsOverview extends StatelessWidget {
  const AuthorsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          // Sidebar
          SidebarWidget(),
          
          // Main content
          Expanded(
            child: AuthorsContent(),
          ),
        ],
      ),
    );
  }
}

class AuthorsContent extends StatefulWidget {
  const AuthorsContent({super.key});

  @override
  State<AuthorsContent> createState() => _AuthorsContentState();
}

class _AuthorsContentState extends State<AuthorsContent> with WidgetsBindingObserver {
  String _sortOption = 'Ime (A-Z)';
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _loadAuthors();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthorProvider>().setSorting('name', 'asc');
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadAuthors();
    }
  }
  
  void _loadAuthors() {
    // Load authors data using pagination
    Future.microtask(() {
      Provider.of<AuthorProvider>(context, listen: false).refresh();
    });
  }
  
  void _handleSortChange(String? value) {
    if (value != null) {
      setState(() {
        _sortOption = value;
      });
      
      String sortBy;
      String sortOrder;
      
      switch (value) {
        case 'Ime (A-Z)':
          sortBy = 'name';
          sortOrder = 'asc';
          break;
        case 'Ime (Z-A)':
          sortBy = 'name';
          sortOrder = 'desc';
          break;
        default:
          sortBy = 'name';
          sortOrder = 'asc';
          break;
      }
      
      context.read<AuthorProvider>().setSorting(sortBy, sortOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0, left: 80.0, right: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Pregled autora',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Build toolbar
          _buildToolbar(),
          
          const SizedBox(height: 24),
          
          // Authors grid
          Expanded(
            child: _buildAuthorsGrid(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToolbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search using our new component
        Expanded(
          child: SearchInput(
            label: 'Pretraži',
            hintText: 'Pretraži autore',
            borderColor: Colors.grey.shade300,
            onChanged: (value) {
              context.read<AuthorProvider>().setSearchQuery(value);
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Sort dropdown
        ZSDropdown<String>(
          label: 'Sortiraj',
          value: _sortOption,
          width: 180,
          items: const [
            DropdownMenuItem(value: 'Ime (A-Z)', child: Text('Ime (A-Z)')),
            DropdownMenuItem(value: 'Ime (Z-A)', child: Text('Ime (Z-A)')),
          ],
          onChanged: (value) {
            _handleSortChange(value);
          },
          borderColor: Colors.grey.shade300,
        ),
        const SizedBox(width: 16),
        
        // Filter
        ZSButton(
          onPressed: () {},
          text: 'Postavi filtre',
          label: 'Filtriraj',
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
        const SizedBox(width: 16),
        
        // Add button
        ZSButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthorAddScreen(),
              ),
            ).then((_) {
              // Refresh authors when returning from add screen
              _loadAuthors();
            });
          },
          text: 'Dodaj autora',
          backgroundColor: const Color(0xFFE5FFEE),
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
      ],
    );
  }
  
  Widget _buildAuthorsGrid() {
    return Consumer<AuthorProvider>(
      builder: (ctx, authorProvider, child) {
        if (authorProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (authorProvider.error != null && authorProvider.authors.isEmpty) {
          return Center(
            child: Text(
              'Greška: ${authorProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final authors = authorProvider.authors;
        
        if (authors.isEmpty) {
          return const EmptyState(
            icon: Icons.person_outline,
            title: 'Nema autora za prikaz',
            description: 'Trenutno nema autora u sistemu.\nDodajte novog autora da biste počeli.',
          );
        }
        
        return Stack(
          children: [
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 100),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Authors grid
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 40,
                      mainAxisSpacing: 40,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final author = authors[index];
                        return ZSCard.fromAuthor(
                          context,
                          author,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuthorDetailOverview(
                                  author: author,
                                ),
                              ),
                            ).then((_) {
                              _loadAuthors();
                            });
                          },
                        );
                      },
                      childCount: authors.length,
                    ),
                  ),
                  
                  if (authorProvider.hasMoreData || authorProvider.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 40),
                        child: PaginationControlsWidget(
                          currentItemCount: authorProvider.authors.length,
                          totalCount: authorProvider.totalCount,
                          hasMoreData: authorProvider.hasMoreData,
                          isLoadingMore: authorProvider.isLoadingMore,
                          onLoadMore: () => authorProvider.loadMore(),
                          currentPageSize: authorProvider.pageSize,
                          onPageSizeChanged: (newSize) => authorProvider.setPageSize(newSize),
                          itemName: 'autora',
                          loadMoreText: 'Učitaj više autora',
                        ),
                      ),
                    )
                  else
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 60),
                    ),
                ],
              ),
            ),
            
            // Search loading indicator
            SearchLoadingIndicator(
              isVisible: authorProvider.isUpdating,
              text: 'Pretražujem autore...',
              top: 20,
            ),
          ],
        );
      },
    );
  }
} 