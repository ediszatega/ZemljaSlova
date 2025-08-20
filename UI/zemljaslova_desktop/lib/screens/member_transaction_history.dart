import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/transaction_service.dart';
import '../widgets/zs_button.dart';
import '../widgets/sidebar.dart';
import '../models/order.dart';
import '../models/book_transaction.dart';

enum TransactionType {
  all,
  vouchers,
  books,
  tickets,
  memberships,
  rentals,
}

class MemberTransactionHistory extends StatefulWidget {
  final int? memberId;
  
  const MemberTransactionHistory({
    super.key,
    this.memberId,
  });

  @override
  State<MemberTransactionHistory> createState() => _MemberTransactionHistoryState();
}

class _MemberTransactionHistoryState extends State<MemberTransactionHistory> {
  TransactionType _selectedFilter = TransactionType.all;
  bool _isLoading = false;
  List<Order> _transactions = [];
  List<BookTransaction> _rentalTransactions = [];
  String? _error;
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMoreData = true;
  late TransactionService _transactionService;
  
  // Map to store order items for each order
  final Map<int, List<OrderItem>> _orderItemsMap = {};
  final Map<int, bool> _loadingOrderItems = {};

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<AuthProvider>(context, listen: false).apiService;
    _transactionService = TransactionService(apiService: apiService);
    _loadTransactions();
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _transactions.clear();
        _rentalTransactions.clear();
        _hasMoreData = true;
        _orderItemsMap.clear(); // Clear order items when refreshing
      });
    }

    if (!_hasMoreData || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Order> newTransactions = [];
      List<BookTransaction> newRentalTransactions = [];
      int totalCount = 0;

      if (_selectedFilter == TransactionType.rentals) {
        try {
          if (widget.memberId != null) {
            newRentalTransactions = await _transactionService.getMemberRentalTransactions(widget.memberId!);
            totalCount = newRentalTransactions.length;
          }
        } catch (e) {
          debugPrint('Failed to load rental transactions: $e');
        }
      } else {
        final response = await _transactionService.getMemberTransactions(
          page: _currentPage,
          pageSize: 20,
          transactionType: _getTransactionTypeString(_selectedFilter),
          memberId: widget.memberId,
        );

        newTransactions = _transactionService.mapOrdersFromResponse(response);
        totalCount = _transactionService.getTotalCount(response);

        if (_selectedFilter == TransactionType.all) {
          try {
            if (widget.memberId != null) {
              newRentalTransactions = await _transactionService.getMemberRentalTransactions(widget.memberId!);
              totalCount += newRentalTransactions.length;
            }
          } catch (e) {
            debugPrint('Failed to load rental transactions: $e');
          }
        }

        for (final transaction in newTransactions) {
          _fetchOrderItems(transaction);
        }
      }

      setState(() {
        if (refresh) {
          _transactions = newTransactions;
          _rentalTransactions = newRentalTransactions;
        } else {
          _transactions.addAll(newTransactions);
          _rentalTransactions.addAll(newRentalTransactions);
        }
        _totalCount = totalCount;
        _currentPage++;
        _hasMoreData = _transactions.length + _rentalTransactions.length < _totalCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Greška pri učitavanju transakcija: $e';
        _isLoading = false;
      });
    }
  }

  String? _getTransactionTypeString(TransactionType type) {
    String? result;
    switch (type) {
      case TransactionType.all:
        result = null;
        break;
      case TransactionType.vouchers:
        result = 'vouchers';
        break;
      case TransactionType.books:
        result = 'books';
        break;
      case TransactionType.tickets:
        result = 'tickets';
        break;
      case TransactionType.memberships:
        result = 'memberships';
        break;
      case TransactionType.rentals:
        result = 'rentals';
        break;
    }
    return result;
  }

  String _getTransactionTypeDisplayName(TransactionType type) {
    switch (type) {
      case TransactionType.all:
        return 'Sve';
      case TransactionType.vouchers:
        return 'Vaučeri';
      case TransactionType.books:
        return 'Knjige';
      case TransactionType.tickets:
        return 'Ulaznice';
      case TransactionType.memberships:
        return 'Članstva';
      case TransactionType.rentals:
        return 'Iznajmljivanja';
    }
  }

  Future<void> _fetchOrderItems(Order order) async {
    if (_orderItemsMap.containsKey(order.id) || _loadingOrderItems[order.id] == true) {
      return;
    }

    setState(() {
      _loadingOrderItems[order.id] = true;
    });

    try {
      final orderItems = await _transactionService.getOrderItemsByOrderId(order.id);
      
      setState(() {
        _orderItemsMap[order.id] = orderItems;
        _loadingOrderItems[order.id] = false;
      });
    } catch (e) {
      setState(() {
        _loadingOrderItems[order.id] = false;
      });
    }
  }

  String _getTransactionTypeText(Order order) {
    final orderItems = _orderItemsMap[order.id];
    
    if (orderItems == null || orderItems.isEmpty) {
      return 'Transakcija ${order.id}';
    }

    if (orderItems.any((item) => item.bookId != null)) {
      final bookItem = orderItems.firstWhere((item) => item.bookId != null);
      if (bookItem.book != null && bookItem.book!.title.isNotEmpty) {
        return bookItem.book!.title;
      }
      return 'Knjiga ID: ${bookItem.bookId}';
    }

    if (orderItems.any((item) => item.membershipId != null)) {
      return 'Članstvo';
    } else if (orderItems.any((item) => item.voucherId != null)) {
      final voucherItem = orderItems.firstWhere((item) => item.voucherId != null);
      if (voucherItem.voucher != null) {
        return 'Vaučer ${voucherItem.voucher!.value.toStringAsFixed(0)} KM';
      }
      return 'Vaučer ${voucherItem.voucherId} KM';
    } else if (orderItems.any((item) => item.ticketTypeId != null)) {
      final ticketItem = orderItems.firstWhere((item) => item.ticketTypeId != null);
      if (ticketItem.ticketType != null) {
        return 'Ulaznica: ${ticketItem.ticketType!.name}';
      }
      return 'Ulaznica ID: ${ticketItem.ticketTypeId}';
    }
    
    return 'Transakcija ${order.id}';
  }

  IconData _getTransactionTypeIcon(Order order) {
    final orderItems = _orderItemsMap[order.id];
    if (orderItems == null || orderItems.isEmpty) {
      return Icons.shopping_cart;
    }

    if (orderItems.any((item) => item.membershipId != null)) {
      return Icons.card_membership;
    } else if (orderItems.any((item) => item.voucherId != null)) {
      return Icons.card_giftcard;
    } else if (orderItems.any((item) => item.bookId != null)) {
      return Icons.book;
    } else if (orderItems.any((item) => item.ticketTypeId != null)) {
      return Icons.event;
    }
    return Icons.shopping_cart;
  }

  @override
  Widget build(BuildContext context) {
    // Combined list of all transactions
    final allTransactions = <dynamic>[];
    
    // Add order transactions
    allTransactions.addAll(_transactions);
    
    // Add rental transactions
    allTransactions.addAll(_rentalTransactions);
    
    // Sort by date (most recent first)
    allTransactions.sort((a, b) {
      DateTime dateA = a is Order ? a.purchasedAt : (a as BookTransaction).createdAt;
      DateTime dateB = b is Order ? b.purchasedAt : (b as BookTransaction).createdAt;
      return dateB.compareTo(dateA);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          const SidebarWidget(),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 44, left: 80.0, right: 80.0, bottom: 44.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Nazad'),
                    ),
                    const SizedBox(height: 24),
                    
                    // Header
                    const Text(
                      'Historija transakcija',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pregled svih transakcija',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Filter buttons
                    _buildFilterButtons(),
                    const SizedBox(height: 24),
                    
                    // Transaction list
                    _buildTransactionList(allTransactions),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: TransactionType.values.map((type) {
        return ZSButton(
          text: _getTransactionTypeDisplayName(type),
          backgroundColor: _selectedFilter == type ? const Color(0xFF28A745) : Colors.grey.shade200,
          foregroundColor: _selectedFilter == type ? Colors.white : Colors.black87,
          onPressed: () {
            setState(() {
              _selectedFilter = type;
            });
            _loadTransactions(refresh: true);
          },
          width: null,
        );
      }).toList(),
    );
  }

  Widget _buildTransactionList(List<dynamic> transactions) {
    if (_isLoading && transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null && transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Greška',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ZSButton(
                text: 'Pokušaj ponovo',
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                onPressed: () => _loadTransactions(refresh: true),
                width: 200,
              ),
            ],
          ),
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Nema transakcija',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nemate još nijednu transakciju',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Transaction cards
        ...transactions.map((transaction) => _buildTransactionCard(transaction)).toList(),
        
        // Loading indicator
        if (_hasMoreData)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionCard(dynamic transaction) {
    if (transaction is Order) {
      return _buildOrderTransactionCard(transaction);
    } else if (transaction is BookTransaction) {
      return _buildRentalTransactionCard(transaction);
    }
    return const SizedBox.shrink();
  }

  Widget _buildOrderTransactionCard(Order transaction) {
    final isLoading = _loadingOrderItems[transaction.id] == true;
    final orderItems = _orderItemsMap[transaction.id] ?? [];
    
    // Calculate total points earned for this order
    int totalPointsEarned = 0;
    for (final item in orderItems) {
      totalPointsEarned += item.pointsEarned ?? 0;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transaction type icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF28A745).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading 
              ? const CircularProgressIndicator(strokeWidth: 2)
              : Icon(
                  _getTransactionTypeIcon(transaction),
                  color: const Color(0xFF28A745),
                  size: 28,
                ),
          ),
          const SizedBox(width: 20),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTypeText(transaction),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.purchasedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${transaction.amount.toStringAsFixed(2)} KM',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF28A745),
                      ),
                    ),
                    if (totalPointsEarned > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+$totalPointsEarned bodova',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalTransactionCard(BookTransaction transaction) {    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transaction type icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.library_books,
              color: Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Iznajmljeno: ${transaction.book?.title ?? 'Knjiga ID: ${transaction.bookId}'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Iznajmljeno',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (transaction.pointsEarned != null && transaction.pointsEarned! > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${transaction.pointsEarned} bodova',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
