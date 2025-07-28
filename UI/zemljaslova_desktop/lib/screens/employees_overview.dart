import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/employee_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/empty_state.dart';
import '../widgets/pagination_controls_widget.dart';
import '../widgets/search_loading_indicator.dart';
import '../widgets/filter_dialog.dart';
import '../utils/filter_configurations.dart';
import '../models/employee_filters.dart';
import '../screens/employee_details_overview.dart';
import '../screens/employee_add.dart';

class EmployeesOverview extends StatelessWidget {
  const EmployeesOverview({super.key});

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
            child: EmployeesContent(),
          ),
        ],
      ),
    );
  }
}

class EmployeesContent extends StatefulWidget {
  const EmployeesContent({super.key});

  @override
  State<EmployeesContent> createState() => _EmployeesContentState();
}

class _EmployeesContentState extends State<EmployeesContent> with WidgetsBindingObserver {
  String _sortOption = 'Ime (A-Z)';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadEmployees();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().setSorting('name', 'asc');
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadEmployees();
    }
  }
  
  void _loadEmployees() {
    // Load employees data using pagination
    Future.microtask(() {
      Provider.of<EmployeeProvider>(context, listen: false).refresh(isUserIncluded: true);
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
      
      context.read<EmployeeProvider>().setSorting(sortBy, sortOrder);
    }
  }

  void _showFiltersDialog() {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        title: 'Filtriraj uposlenike',
        fields: FilterConfigurations.getEmployeeFilters(context),
        initialValues: employeeProvider.filters.toMap(),
        onApplyFilters: (Map<String, dynamic> values) {
          final filters = EmployeeFilters.fromMap(values);
          employeeProvider.setFilters(filters);
        },
        onClearFilters: () {
          employeeProvider.clearFilters();
        },
      ),
    );
  }

  int _getActiveFilterCount(EmployeeFilters filters) {
    int count = 0;
    if (filters.gender != null) count++;
    if (filters.accessLevel != null) count++;
    return count;
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
            'Pregled uposlenika',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Build toolbar
          _buildToolbar(),
          
          const SizedBox(height: 24),
          
          // Employees grid
          Expanded(
            child: _buildEmployeesGrid(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToolbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: SearchInput(
            label: 'Pretraži',
            hintText: 'Pretraži uposljenike',
            controller: _searchController,
            borderColor: Colors.grey.shade300,
            onChanged: (value) {
              context.read<EmployeeProvider>().setSearchQuery(value);
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
        
        Consumer<EmployeeProvider>(
          builder: (context, employeeProvider, child) {
            final hasActiveFilters = employeeProvider.filters.hasActiveFilters;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ZSButton(
                  onPressed: () {
                    _showFiltersDialog();
                  },
                  text: hasActiveFilters ? 'Filteri aktivni (${_getActiveFilterCount(employeeProvider.filters)})' : 'Postavi filtre',
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
                        employeeProvider.clearFilters();
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
        
        ZSButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmployeeAddScreen(),
              ),
            ).then((_) {
              // Refresh employees when returning from add screen
              _loadEmployees();
            });
          },
          text: 'Dodaj uposlenika',
          backgroundColor: const Color(0xFFE5FFEE),
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
      ],
    );
  }
  
  Widget _buildEmployeesGrid() {
    return Consumer<EmployeeProvider>(
      builder: (ctx, employeeProvider, child) {
        if (employeeProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (employeeProvider.error != null && employeeProvider.employees.isEmpty) {
          return Center(
            child: Text(
              'Greška: ${employeeProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final employees = employeeProvider.employees;
        
        if (employees.isEmpty) {
          return const EmptyState(
            icon: Icons.badge,
            title: 'Nema zaposlenika za prikaz',
            description: 'Trenutno nema zaposlenih u sistemu.\nDodajte novog zaposlenog da biste počeli.',
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
                  // Employees grid
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 40,
                      mainAxisSpacing: 40,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final employee = employees[index];
                        return ZSCard.fromEmployee(
                          context,
                          employee,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmployeeDetailsOverview(
                                  employee: employee,
                                ),
                              ),
                            ).then((_) {
                              _loadEmployees();
                            });
                          },
                        );
                      },
                      childCount: employees.length,
                    ),
                  ),
                  
                  if (employeeProvider.hasMoreData || employeeProvider.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 40),
                        child: PaginationControlsWidget(
                          currentItemCount: employeeProvider.employees.length,
                          totalCount: employeeProvider.totalCount,
                          hasMoreData: employeeProvider.hasMoreData,
                          isLoadingMore: employeeProvider.isLoadingMore,
                          onLoadMore: () => employeeProvider.loadMore(),
                          currentPageSize: employeeProvider.pageSize,
                          onPageSizeChanged: (newSize) => employeeProvider.setPageSize(newSize),
                          itemName: 'uposlenika',
                          loadMoreText: 'Učitaj više uposlenika',
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
              isVisible: employeeProvider.isUpdating,
              text: 'Pretražujem uposljenike...',
              top: 20,
            ),
          ],
        );
      },
    );
  }
} 