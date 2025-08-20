import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../services/transaction_service.dart';
import '../services/api_service.dart';
import '../widgets/zs_button.dart';
import '../models/order.dart';

enum TransactionType {
  all,
  vouchers,
  books,
  tickets,
  memberships,
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
      final response = await _transactionService.getMemberTransactions(
        page: _currentPage,
        pageSize: 10,
        transactionType: _getTransactionTypeString(_selectedFilter),
      );

      final newTransactions = _transactionService.mapOrdersFromResponse(response);
      final totalCount = _transactionService.getTotalCount(response);

      setState(() {
        if (refresh) {
          _transactions = newTransactions;
        } else {
          _transactions.addAll(newTransactions);
        }
        _totalCount = totalCount;
        _currentPage++;
        _hasMoreData = _transactions.length < totalCount;
        _isLoading = false;
      });

      // Fetch order items for all new transactions
      for (final transaction in newTransactions) {
        _fetchOrderItems(transaction);
      }
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Historija transakcija'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              'Pregled svih vaših kupovina',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterButtons(),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TransactionType.values.map((type) {
            final isSelected = _selectedFilter == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ZSButton(
                text: _getFilterText(type),
                backgroundColor: isSelected ? const Color(0xFF28A745) : Colors.white,
                foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
                borderColor: isSelected ? const Color(0xFF28A745) : Colors.grey.shade300,
                onPressed: () {
                  setState(() {
                    _selectedFilter = type;
                  });
                  _loadTransactions(refresh: true);
                },
                paddingVertical: 8,
                paddingHorizontal: 16,
                fontSize: 12,
                width: 100,
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
    }
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
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
              onPressed: _loadTransactions,
              width: 200,
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _transactions.length + (_hasMoreData ? 1 : 0),
             itemBuilder: (context, index) {
         if (index == _transactions.length) {
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
         
         final transaction = _transactions[index];
         return _buildTransactionCard(transaction);
       },
    );
  }

    Widget _buildTransactionCard(Order transaction) {
    final isLoading = _loadingOrderItems[transaction.id] == true;
    
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
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.purchasedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${transaction.amount.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF28A745),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.paymentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(transaction.paymentStatus),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(transaction.paymentStatus),
                  ),
                ),
              ),
            ],
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
