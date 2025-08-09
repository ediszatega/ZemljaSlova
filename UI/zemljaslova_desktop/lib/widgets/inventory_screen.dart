import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../services/inventory_service.dart';

abstract class InventoryTransaction {
  int get activityTypeId;
  int get quantity;
  DateTime get createdAt;
  String? get data;
}

class InventoryScreen<T extends InventoryTransaction> extends StatefulWidget {
  final int itemId;
  final String itemTitle;
  final InventoryService<T> inventoryService;
  final String itemLabel;
  final String sellButtonText;
  final String sellSuccessMessage;
  final String insufficientStockMessage;
  final bool isForRent;
  
  const InventoryScreen({
    super.key,
    required this.itemId,
    required this.itemTitle,
    required this.inventoryService,
    required this.itemLabel,
    required this.sellButtonText,
    required this.sellSuccessMessage,
    required this.insufficientStockMessage,
    this.isForRent = false,
  });

  @override
  State<InventoryScreen<T>> createState() => _InventoryScreenState<T>();
}

class _InventoryScreenState<T extends InventoryTransaction> extends State<InventoryScreen<T>> {
  int _currentQuantity = 0;
  bool _isLoading = true;
  bool _isAddingStock = false;
  bool _isSellingItems = false;
  List<T> _transactions = [];
  
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _sellQuantityController = TextEditingController();
  final TextEditingController _stockDataController = TextEditingController();
  final TextEditingController _sellDataController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }
  
  @override
  void dispose() {
    _stockQuantityController.dispose();
    _sellQuantityController.dispose();
    _stockDataController.dispose();
    _sellDataController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInventoryData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final quantity = await widget.inventoryService.getCurrentQuantity(widget.itemId);
      final transactions = await widget.inventoryService.getTransactionsById(widget.itemId);
      
      setState(() {
        _currentQuantity = quantity;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška prilikom učitavanja podataka: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _addStock() async {
    if (_stockQuantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unesite količinu za dodavanje'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final quantity = int.tryParse(_stockQuantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Količina mora biti pozitivan broj'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isAddingStock = true;
    });
    
    try {
      final success = await widget.inventoryService.addStock(
        id: widget.itemId,
        quantity: quantity,
        data: _stockDataController.text.isNotEmpty ? _stockDataController.text : null,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Količina uspješno dodana'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _stockQuantityController.clear();
        _stockDataController.clear();
        
        // Reload data
        await _loadInventoryData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška prilikom dodavanja količine'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAddingStock = false;
      });
    }
  }
  
  Future<void> _sellItems() async {
    if (_sellQuantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unesite količinu za prodaju'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final quantity = int.tryParse(_sellQuantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Količina mora biti pozitivan broj'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check availability
    final isAvailable = await widget.inventoryService.isAvailableForPurchase(widget.itemId, quantity);
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.insufficientStockMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSellingItems = true;
    });
    
    try {
      bool success;
      if (widget.isForRent) {
        success = await widget.inventoryService.removeItems(
          id: widget.itemId,
          quantity: quantity,
          data: _sellDataController.text.isNotEmpty ? _sellDataController.text : null,
        );
      } else {
        success = await widget.inventoryService.sellItems(
          id: widget.itemId,
          quantity: quantity,
          data: _sellDataController.text.isNotEmpty ? _sellDataController.text : null,
        );
      }
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.sellSuccessMessage),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _sellQuantityController.clear();
        _sellDataController.clear();
        
        // Reload data
        await _loadInventoryData();
      } else {
        String errorMesage = "";
        if(widget.isForRent) {
          errorMesage = "uklanjanja knjiga";
        } else if (!widget.isForRent && widget.itemLabel == "knjiga") {
          errorMesage = "prodaje knjigu";
        } else if (!widget.isForRent && widget.itemLabel == "ulaznica") {
          errorMesage = "prodaje ulaznicu";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška prilikom $errorMesage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSellingItems = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          const SidebarWidget(),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0, left: 80.0, right: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Upravljanje inventarom: ${widget.itemTitle}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  if (_isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side - Inventory management
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: _buildInventoryManagement(),
                            ),
                          ),
                          
                          const SizedBox(width: 32),
                          
                                                     // Right side - Transaction history
                           Expanded(
                             flex: 1,
                             child: _buildTransactionHistory(),
                           ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInventoryManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        
        // Current quantity card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trenutno stanje',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_currentQuantity ${widget.itemLabel}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Add stock section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dodaj količinu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                ZSInput(
                  label: 'Količina',
                  controller: _stockQuantityController,
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 16),
                
                ZSInput(
                  label: 'Napomena (opciono)',
                  controller: _stockDataController,
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ZSButton(
                    text: _isAddingStock ? 'Dodavanje...' : 'Dodaj količinu',
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue,
                    onPressed: _isAddingStock ? () {} : () => _addStock(),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Sell items section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isForRent ? 'Ukloni knjigu' : 'Prodaj ${widget.itemLabel}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                ZSInput(
                  label: 'Količina',
                  controller: _sellQuantityController,
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 16),
                
                ZSInput(
                  label: 'Napomena (opciono)',
                  controller: _sellDataController,
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ZSButton(
                    text: _isSellingItems ? 'Prodaja...' : (widget.isForRent ? 'Ukloni knjigu' : widget.sellButtonText),
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green,
                    onPressed: _isSellingItems ? () {} : () => _sellItems(),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    // Convert UTC to local time
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    
    return '$day-$month-$year $hour:$minute';
  }
  
  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Historija transakcija',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _loadInventoryData,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: () {
            // Filter transactions to show only inventory activities (exclude rental)
            final inventoryTransactions = _transactions.where((transaction) => 
              transaction.activityTypeId == 1 ||
              transaction.activityTypeId == 2 ||
              transaction.activityTypeId == 3
            ).toList();
            
            return inventoryTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'Nema transakcija za prikaz',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: inventoryTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = inventoryTransactions[index];
                      final isStock = transaction.activityTypeId == 1;
                      final isRemove = transaction.activityTypeId == 3;
                      final isSold = transaction.activityTypeId == 2;
                      
                      String activityTitle;
                      IconData activityIcon;
                      Color activityColor;
                      
                      if (isStock) {
                        activityTitle = 'Dodavanje količine';
                        activityIcon = Icons.add_circle;
                        activityColor = Colors.green;
                      } else if (isRemove) {
                        activityTitle = 'Uklanjanje količine';
                        activityIcon = Icons.remove_circle;
                        activityColor = Colors.red;
                      } else if (isSold) {
                        activityTitle = 'Prodaja ${widget.itemLabel}';
                        activityIcon = Icons.remove_circle;
                        activityColor = Colors.red;
                      } else {
                        activityTitle = 'Ostala aktivnost';
                        activityIcon = Icons.help;
                        activityColor = Colors.grey;
                      }
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            activityIcon,
                            color: activityColor,
                          ),
                          title: Text(
                            activityTitle,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Količina: ${transaction.quantity}'),
                              if (transaction.data != null && transaction.data!.isNotEmpty)
                                Text('Napomena: ${transaction.data}'),
                                Text(
                                 'Datum: ${_formatDate(transaction.createdAt)}',
                                 style: const TextStyle(fontSize: 12),
                               ),
                            ],
                          ),
                          trailing: Text(
                            '${isStock ? '+' : '-'}${transaction.quantity}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isStock ? Colors.green : activityColor,
                            ),
                          ),
                        ),
                      );
                    },
                  );
          }(),
        ),
      ],
    );
  }
} 