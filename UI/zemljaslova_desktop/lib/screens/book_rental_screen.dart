import 'package:flutter/material.dart';
import '../models/book_transaction.dart';
import '../models/member.dart';
import '../services/inventory_service.dart';
import '../services/member_service.dart';
import '../services/api_service.dart';
import '../utils/authorization.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_dropdown.dart';

class BookRentalScreen extends StatefulWidget {
  final int bookId;
  final String bookTitle;
  
  const BookRentalScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<BookRentalScreen> createState() => _BookRentalScreenState();
}

class _BookRentalScreenState extends State<BookRentalScreen> {
  int _currentQuantity = 0;
  bool _isLoading = true;
  bool _isRentingItems = false;
  bool _isReturningItems = false;
  List<BookTransaction> _transactions = [];
  
  final TextEditingController _rentQuantityController = TextEditingController();
  final TextEditingController _returnQuantityController = TextEditingController();
  
  // Rental specific variables
  Member? _selectedMember;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  DateTime _returnDate = DateTime.now();
  List<Member> _members = [];
  bool _loadingMembers = false;
  
  final InventoryService<BookTransaction> _inventoryService = InventoryService<BookTransaction>(
    ApiService(),
    'BookTransaction/book',
    BookTransaction.fromJson,
  );
  final MemberService _memberService = MemberService(ApiService());
  
  @override
  void initState() {
    super.initState();
    _loadInventoryData();
    _loadMembers();
  }
  
  @override
  void dispose() {
    _rentQuantityController.dispose();
    _returnQuantityController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInventoryData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // For rental books, use physical stock instead of current quantity
      final quantity = await _inventoryService.getPhysicalStock(widget.bookId);
      final transactions = await _inventoryService.getTransactionsById(widget.bookId);
      
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
  
  Future<void> _loadMembers() async {
    setState(() {
      _loadingMembers = true;
    });
    
    try {
      final response = await _memberService.fetchMembers(
        isUserIncluded: true,
        pageSize: 100,
      );
      
      setState(() {
        _members = response['members'] as List<Member>;
        _loadingMembers = false;
      });
    } catch (e) {
      setState(() {
        _loadingMembers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška prilikom učitavanja članova: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rentItems() async {
    if (_rentQuantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unesite količinu za iznajmljivanje'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Odaberite člana koji iznajmljuje knjigu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final quantity = int.tryParse(_rentQuantityController.text);
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
    final isAvailable = await _inventoryService.isAvailableForRental(widget.bookId, quantity);
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
      _isRentingItems = true;
    });
    
    try {
      // Create formatted rental data
      final formattedStartDate = _formatDateOnly(_startDate);
      final formattedEndDate = _formatDateOnly(_endDate);
      final employeeName = Authorization.email ?? 'Nepoznat zaposlenik'; // Placeholder until we have employee name service
      final rentalDataText = 'MemberId:${_selectedMember!.id}\nKorisnik: ${_selectedMember!.fullName}\nUposlenik: $employeeName\nIzdato na period: $formattedStartDate - $formattedEndDate';
      
      final success = await _inventoryService.rentItems(
        id: widget.bookId,
        quantity: quantity,
        data: rentalDataText,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Knjige uspješno iznajmljene'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _rentQuantityController.clear();
        _selectedMember = null;
        _startDate = DateTime.now();
        _endDate = DateTime.now().add(const Duration(days: 30));
        
        // Reload data
        await _loadInventoryData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška prilikom iznajmljivanja knjiga'),
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
        _isRentingItems = false;
      });
    }
  }

  Future<void> _returnItems() async {
    if (_returnQuantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unesite količinu za vraćanje'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final quantity = int.tryParse(_returnQuantityController.text);
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
      _isReturningItems = true;
    });
    
    try {
      // Create formatted return data
      final formattedReturnDate = _formatDateOnly(_returnDate);
      final employeeName = Authorization.email ?? 'Nepoznat zaposlenik';
      final returnDataText = 'Vraćeno: $formattedReturnDate\nUposlenik: $employeeName';
      
      final success = await _inventoryService.returnItems(
        id: widget.bookId,
        quantity: quantity,
        data: returnDataText,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Knjige uspješno vraćene'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _returnQuantityController.clear();
        _returnDate = DateTime.now();
        
        // Reload data
        await _loadInventoryData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška prilikom vraćanja knjiga'),
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
        _isReturningItems = false;
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
                        'Upravljanje iznajmljivanjem: ${widget.bookTitle}',
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
                          // Left side - Rental management
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: _buildRentalManagement(),
                            ),
                          ),
                          
                          const SizedBox(width: 32),
                          
                          // Right side - Rental history
                          Expanded(
                            flex: 1,
                            child: _buildRentalHistory(),
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
  
  Widget _buildRentalManagement() {
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
                  'Dostupno za iznajmljivanje',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_currentQuantity knjiga',
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
        
        // Rent books section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Iznajmi knjige',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                ZSInput(
                  label: 'Količina',
                  controller: _rentQuantityController,
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 16),
                
                // Member selection dropdown
                if (_loadingMembers)
                  const Center(child: CircularProgressIndicator())
                else
                  ZSDropdown<Member?>(
                    label: 'Član',
                    value: _selectedMember,
                    items: [
                      const DropdownMenuItem<Member?>(
                        value: null,
                        child: Text('Odaberite člana'),
                      ),
                      ..._members.map((member) => DropdownMenuItem<Member?>(
                        value: member,
                        child: Text(member.fullName),
                      )).toList(),
                    ],
                    onChanged: (Member? value) {
                      setState(() {
                        _selectedMember = value;
                      });
                    },
                  ),
                
                const SizedBox(height: 16),
                
                // Date selection
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Datum početka:'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _startDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(_formatDateOnly(_startDate)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Datum završetka:'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: _startDate,
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _endDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(_formatDateOnly(_endDate)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ZSButton(
                    text: _isRentingItems ? 'Iznajmljivanje...' : 'Iznajmi knjige',
                    backgroundColor: Colors.purple.shade50,
                    foregroundColor: Colors.purple,
                    onPressed: _isRentingItems ? () {} : () => _rentItems(),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Return books section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vrati knjige',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                ZSInput(
                  label: 'Količina',
                  controller: _returnQuantityController,
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 16),
                
                // Return date selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Datum vraćanja:'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _returnDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null) {
                          setState(() {
                            _returnDate = date;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(_formatDateOnly(_returnDate)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ZSButton(
                    text: _isReturningItems ? 'Vraćanje...' : 'Vrati knjige',
                    backgroundColor: Colors.teal.shade50,
                    foregroundColor: Colors.teal,
                    onPressed: _isReturningItems ? () {} : () => _returnItems(),
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
  
  String _formatDateOnly(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    
    return '$day-$month-$year';
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
  
  Widget _buildRentalHistory() {
    // Filter transactions to show only rental activities
    final rentalTransactions = _transactions.where((transaction) => 
      transaction.activityTypeId == 4
    ).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Historija iznajmljivanja',
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
          child: rentalTransactions.isEmpty
              ? const Center(
                  child: Text(
                    'Nema transakcija za prikaz',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: rentalTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = rentalTransactions[index];
                    
                    const activityTitle = 'Iznajmljivanje knjige';
                    const activityIcon = Icons.remove_circle;
                    const activityColor = Colors.red;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          activityIcon,
                          color: activityColor,
                        ),
                        title: const Text(
                          activityTitle,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Količina: ${transaction.quantity}'),
                            if (transaction.data != null && transaction.data!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              ...transaction.data!.split('\n').map((line) => 
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    line,
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                )
                              ).toList(),
                            ],
                            const SizedBox(height: 4),
                            Text(
                             'Datum transakcije: ${_formatDate(transaction.createdAt)}',
                             style: const TextStyle(fontSize: 11, color: Colors.grey),
                           ),
                          ],
                        ),
                        trailing: Text(
                          '-${transaction.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: activityColor,
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
