import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../services/transaction_service.dart';
import '../services/api_service.dart';
import '../widgets/zs_button.dart';
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
  const MemberTransactionHistory({super.key});

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
  final TransactionService _transactionService = TransactionService(apiService: ApiService());
  
  // Map to store order items for each order
  final Map<int, List<OrderItem>> _orderItemsMap = {};
  final Map<int, bool> _loadingOrderItems = {};

  @override
  void initState() {
    super.initState();
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

    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Order> newTransactions = [];
      List<BookTransaction> newRentalTransactions = [];
      int totalCount = 0;

      // Handle different filter types
      if (_selectedFilter == TransactionType.rentals) {
        try {
          final memberProvider = context.read<MemberProvider>();
          if (memberProvider.currentMember != null) {
            newRentalTransactions = await _transactionService.getMemberRentalTransactions(memberProvider.currentMember!.id);
            totalCount = newRentalTransactions.length;
          }
        } catch (e) {
          debugPrint('Failed to load rental transactions: $e');
        }
      } else {
        final response = await _transactionService.getMemberTransactions(
          page: _currentPage,
          pageSize: 10,
          transactionType: _getTransactionTypeString(_selectedFilter),
        );

        newTransactions = _transactionService.mapOrdersFromResponse(response);
        totalCount = _transactionService.getTotalCount(response);

        if (_selectedFilter == TransactionType.all) {
          try {
            final memberProvider = context.read<MemberProvider>();
            if (memberProvider.currentMember != null) {
              debugPrint('[MemberTransactionHistory] Loading rental transactions for member ID: ${memberProvider.currentMember!.id}');
              newRentalTransactions = await _transactionService.getMemberRentalTransactions(memberProvider.currentMember!.id);
              debugPrint('[MemberTransactionHistory] Loaded ${newRentalTransactions.length} rental transactions');
              totalCount += newRentalTransactions.length;
            }
          } catch (e) {
            debugPrint('Failed to load rental transactions: $e');
          }
        }

        // Fetch order items for all new transactions
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
    switch (type) {
      case TransactionType.all:
        return null;
      case TransactionType.vouchers:
        return 'vouchers';
      case TransactionType.books:
        return 'books';
      case TransactionType.tickets:
        return 'tickets';
      case TransactionType.memberships:
        return 'memberships';
      case TransactionType.rentals:
        return 'rentals';
    }
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
      appBar: AppBar(
        title: const Text('Historija transakcija'),
        backgroundColor: const Color(0xFF28A745),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading && _transactions.isEmpty && _rentalTransactions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget()
                    : allTransactions.isEmpty
                        ? _buildEmptyState()
                        : _buildTransactionsList(allTransactions),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TransactionType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getTransactionTypeDisplayName(type)),
                selected: _selectedFilter == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = type;
                  });
                  _loadTransactions(refresh: true);
                },
                backgroundColor: Colors.grey.shade200,
                selectedColor: const Color(0xFF28A745),
                labelStyle: TextStyle(
                  color: _selectedFilter == type ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFilterText(TransactionType type) {
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

  Widget _buildErrorWidget() {
    return Center(
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  Widget _buildTransactionsList(List<dynamic> transactions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: transactions.length + (_hasMoreData ? 1 : 0),
             itemBuilder: (context, index) {
         if (index == transactions.length) {
           if (_hasMoreData) {
             // Use Future.microtask to avoid calling setState during build
             Future.microtask(() => _loadTransactions());
             return const Center(
               child: Padding(
                 padding: EdgeInsets.all(16.0),
                 child: CircularProgressIndicator(),
               ),
             );
           }
           return const SizedBox.shrink();
         }
         
         final transaction = transactions[index];
         return _buildTransactionCard(transaction);
       },
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF28A745).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading 
              ? const CircularProgressIndicator(strokeWidth: 2)
              : Icon(
                  _getTransactionTypeIcon(transaction),
                  color: const Color(0xFF28A745),
                  size: 24,
                ),
          ),
          const SizedBox(width: 16),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTypeText(transaction),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.purchasedAt.day}.${transaction.purchasedAt.month}.${transaction.purchasedAt.year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${transaction.amount.toStringAsFixed(2)} KM',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF28A745),
                      ),
                    ),
                    if (totalPointsEarned > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+$totalPointsEarned bodova',
                          style: TextStyle(
                            fontSize: 12,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.library_books,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Iznajmljeno: ${transaction.book?.title ?? 'Knjiga ID: ${transaction.bookId}'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.createdAt.day}.${transaction.createdAt.month}.${transaction.createdAt.year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Iznajmljeno',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (transaction.pointsEarned != null && transaction.pointsEarned! > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${transaction.pointsEarned} bodova',
                          style: TextStyle(
                            fontSize: 12,
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

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toLowerCase()) {
      case 'completed':
      case 'succeeded':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    if (status == null) return 'Nepoznato';
    
    switch (status.toLowerCase()) {
      case 'completed':
      case 'succeeded':
        return 'Uspješno';
      case 'pending':
        return 'Na čekanju';
      case 'failed':
        return 'Neuspješno';
      case 'cancelled':
        return 'Otkazano';
      default:
        return status;
    }
  }
}
