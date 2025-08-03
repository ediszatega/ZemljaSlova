import 'package:flutter/material.dart';
import '../models/book_transaction.dart';
import '../services/book_inventory_service.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';

class BookInventoryScreen extends StatefulWidget {
  final int bookId;
  final String bookTitle;
  
  const BookInventoryScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<BookInventoryScreen> createState() => _BookInventoryScreenState();
}

class _BookInventoryScreenState extends State<BookInventoryScreen> {
  final BookInventoryService _inventoryService = BookInventoryService(
    ApiService(),
  );
  
  int _currentQuantity = 0;
  bool _isLoading = true;
  bool _isAddingStock = false;
  bool _isSellingBooks = false;
  List<BookTransaction> _transactions = [];
  
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _sellQuantityController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }
  
  @override
  void dispose() {
    _stockQuantityController.dispose();
    _sellQuantityController.dispose();
    _dataController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInventoryData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final quantity = await _inventoryService.getCurrentQuantity(widget.bookId);
      final transactions = await _inventoryService.getTransactionsByBook(widget.bookId);
      
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
      final success = await _inventoryService.addStock(
        bookId: widget.bookId,
        quantity: quantity,
        data: _dataController.text.isNotEmpty ? _dataController.text : null,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stok uspješno dodan'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _stockQuantityController.clear();
        _dataController.clear();
        
        // Reload data
        await _loadInventoryData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška prilikom dodavanja stoka'),
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
  
  Future<void> _sellBooks() async {
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
    final isAvailable = await _inventoryService.isAvailableForPurchase(widget.bookId, quantity);
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nema dovoljno knjiga na stanju'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSellingBooks = true;
    });
    
    try {
      final success = await _inventoryService.sellBooks(
        bookId: widget.bookId,
        quantity: quantity,
        data: _dataController.text.isNotEmpty ? _dataController.text : null,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Knjige uspješno prodane'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _sellQuantityController.clear();
        _dataController.clear();
        
        // Reload data
        await _loadInventoryData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška prilikom prodaje knjiga'),
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
        _isSellingBooks = false;
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
                        'Upravljanje inventarom: ${widget.bookTitle}',
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
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side - Inventory management
                            Expanded(
                              flex: 1,
                              child: _buildInventoryManagement(),
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
        const Text(
          'Upravljanje inventarom',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
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
                  '$_currentQuantity knjiga',
                  style: const TextStyle(
                    fontSize: 24,
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
                  'Dodaj stok',
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
                  controller: _dataController,
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ZSButton(
                    text: _isAddingStock ? 'Dodavanje...' : 'Dodaj stok',
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
        
        // Sell books section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prodaj knjige',
                  style: TextStyle(
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
                
                SizedBox(
                  width: double.infinity,
                  child: ZSButton(
                    text: _isSellingBooks ? 'Prodaja...' : 'Prodaj knjige',
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green,
                    onPressed: _isSellingBooks ? () {} : () => _sellBooks(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Povijest transakcija',
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
        
        Container(
          height: 400,
          child: _transactions.isEmpty
              ? const Center(
                  child: Text(
                    'Nema transakcija za prikaz',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    final isStock = transaction.activityTypeId == 1;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          isStock ? Icons.add_circle : Icons.remove_circle,
                          color: isStock ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          isStock ? 'Dodavanje stoka' : 'Prodaja knjiga',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Količina: ${transaction.quantity}'),
                            if (transaction.data != null && transaction.data!.isNotEmpty)
                              Text('Napomena: ${transaction.data}'),
                            Text(
                              'Datum: ${transaction.createdAt.toString().substring(0, 19)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${isStock ? '+' : '-'}${transaction.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isStock ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
} 