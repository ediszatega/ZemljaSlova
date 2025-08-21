import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../services/reporting_service.dart';
import '../models/reports/books_sold_report.dart';
import '../models/reports/books_rented_report.dart';
import '../services/api_service.dart';

class ReportsOverview extends StatelessWidget {
  const ReportsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
                  const Text(
                    'Izvještaji',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: ReportsSection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportsSection extends StatefulWidget {
  const ReportsSection({super.key});

  @override
  State<ReportsSection> createState() => _ReportsSectionState();
}

class _ReportsSectionState extends State<ReportsSection> {
  final ReportingService _reportingService = ReportingService(ApiService());
  
  String _selectedReportCategory = 'books_sold';
  String _selectedReportType = 'custom';
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  int _selectedQuarter = 1;
  
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  bool _isLoading = false;
  dynamic _currentReport;
  
  final List<String> _reportCategories = [
    'books_sold',
    'books_rented',
  ];
  
  final List<String> _reportCategoryLabels = [
    'Prodaja knjiga',
    'Iznajmljivanje knjiga',
  ];
  
  final List<String> _reportTypes = [
    'custom',
    'month',
    'quarter',
    'year',
  ];
  
  final List<String> _reportTypeLabels = [
    'Prilagođeno razdoblje',
    'Po mjesecu',
    'Po kvartalu',
    'Po godini',
  ];
  
  final List<int> _years = List.generate(10, (index) => DateTime.now().year - 5 + index);
  final List<int> _months = List.generate(12, (index) => index + 1);
  final List<int> _quarters = [1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Report Selection and Configuration
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Category Selection
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Odaberite tip izvještaja',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ZSDropdown<String>(
                        value: _selectedReportCategory,
                        items: _reportCategories.asMap().entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.value,
                            child: Text(_reportCategoryLabels[entry.key]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReportCategory = value!;
                            _currentReport = null; // Clear previous report
                          });
                        },
                        label: 'Kategorija izvještaja',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Report Configuration
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedReportCategory == 'books_sold' 
                          ? 'Izvještaj o prodaji knjiga'
                          : 'Izvještaj o iznajmljivanju knjiga',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: ZSDropdown<String>(
                              value: _selectedReportType,
                              items: _reportTypes.asMap().entries.map((entry) {
                                return DropdownMenuItem(
                                  value: entry.value,
                                  child: Text(_reportTypeLabels[entry.key]),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedReportType = value!;
                                });
                              },
                              label: 'Tip izvještaja',
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          if (_selectedReportType == 'month') ...[
                            Expanded(
                              child: ZSDropdown<int>(
                                value: _selectedMonth,
                                items: _months.map((month) {
                                  return DropdownMenuItem(
                                    value: month,
                                    child: Text(_getMonthName(month)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMonth = value!;
                                  });
                                },
                                label: 'Mjesec',
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          
                          if (_selectedReportType == 'quarter') ...[
                            Expanded(
                              child: ZSDropdown<int>(
                                value: _selectedQuarter,
                                items: _quarters.map((quarter) {
                                  return DropdownMenuItem(
                                    value: quarter,
                                    child: Text('Q$quarter'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedQuarter = value!;
                                  });
                                },
                                label: 'Kvartal',
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          
                          if (_selectedReportType != 'custom') ...[
                            Expanded(
                              child: ZSDropdown<int>(
                                value: _selectedYear,
                                items: _years.map((year) {
                                  return DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value!;
                                  });
                                },
                                label: 'Godina',
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          
                          if (_selectedReportType == 'custom') ...[
                            Expanded(
                              child: _buildDatePicker(
                                'Od datuma',
                                _startDate,
                                (date) => setState(() => _startDate = date),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDatePicker(
                                'Do datuma',
                                _endDate,
                                (date) => setState(() => _endDate = date),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          ZSButton(
                            onPressed: _isLoading ? () {} : () => _generateReport(),
                            text: 'Generiraj izvještaj',
                          ),
                          const SizedBox(width: 16),
                          if (_currentReport != null)
                            ZSButton(
                              onPressed: _downloadPdf,
                              text: 'Preuzmi PDF',
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Report Display
        if (_currentReport != null) ...[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: _buildSummaryCards(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Book Summaries Table
                  if (_hasBookSummaries()) ...[
                    const Text(
                      'Pregled po knjigama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBookSummariesTable(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Transactions Table
                  if (_hasTransactions()) ...[
                    const Text(
                      'Detaljne transakcije',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTransactionsTable(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildSummaryCards() {
    if (_currentReport is BooksSoldReport) {
      final report = _currentReport as BooksSoldReport;
      return [
        Expanded(
          child: _buildSummaryCard(
            'Ukupno prodanih knjiga',
            report.totalBooksSold.toString(),
            Icons.book,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Ukupan prihod',
            '${report.totalRevenue.toStringAsFixed(2)} KM',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Ukupno transakcija',
            report.totalTransactions.toString(),
            Icons.receipt,
            Colors.orange,
          ),
        ),
      ];
    } else if (_currentReport is BooksRentedReport) {
      final report = _currentReport as BooksRentedReport;
      return [
        Expanded(
          child: _buildSummaryCard(
            'Ukupno iznajmljenih knjiga',
            report.totalBooksRented.toString(),
            Icons.book,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Aktivna iznajmljivanja',
            report.totalActiveRentals.toString(),
            Icons.access_time,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Prekoračenja roka',
            report.totalOverdueRentals.toString(),
            Icons.warning,
            Colors.red,
          ),
        ),
      ];
    }
    return [];
  }

  bool _hasBookSummaries() {
    if (_currentReport is BooksSoldReport) {
      return (_currentReport as BooksSoldReport).bookSummaries.isNotEmpty;
    } else if (_currentReport is BooksRentedReport) {
      return (_currentReport as BooksRentedReport).bookSummaries.isNotEmpty;
    }
    return false;
  }

  bool _hasTransactions() {
    if (_currentReport is BooksSoldReport) {
      return (_currentReport as BooksSoldReport).transactions.isNotEmpty;
    } else if (_currentReport is BooksRentedReport) {
      return (_currentReport as BooksRentedReport).transactions.isNotEmpty;
    }
    return false;
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSummariesTable() {
    if (_currentReport is BooksSoldReport) {
      final report = _currentReport as BooksSoldReport;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Naslov knjige')),
            DataColumn(label: Text('Autori')),
            DataColumn(label: Text('Količina')),
            DataColumn(label: Text('Ukupan prihod')),
            DataColumn(label: Text('Prosječna cijena')),
          ],
          rows: report.bookSummaries.map((summary) {
            return DataRow(
              cells: [
                DataCell(Text(summary.bookTitle)),
                DataCell(Text(summary.authorNames)),
                DataCell(Text(summary.totalQuantitySold.toString())),
                DataCell(Text('${summary.totalRevenue.toStringAsFixed(2)} KM')),
                DataCell(Text('${summary.averagePrice.toStringAsFixed(2)} KM')),
              ],
            );
          }).toList(),
        ),
      );
    } else if (_currentReport is BooksRentedReport) {
      final report = _currentReport as BooksRentedReport;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Naslov knjige')),
            DataColumn(label: Text('Autori')),
            DataColumn(label: Text('Broj iznajmljivanja')),
            DataColumn(label: Text('Aktivna')),
            DataColumn(label: Text('Prekoračenja')),
          ],
          rows: report.bookSummaries.map((summary) {
            return DataRow(
              cells: [
                DataCell(Text(summary.bookTitle)),
                DataCell(Text(summary.authorNames)),
                DataCell(Text(summary.totalTimesRented.toString())),
                DataCell(Text(summary.activeRentals.toString())),
                DataCell(Text(summary.overdueRentals.toString())),
              ],
            );
          }).toList(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTransactionsTable() {
    if (_currentReport is BooksSoldReport) {
      final report = _currentReport as BooksSoldReport;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Datum')),
            DataColumn(label: Text('Knjiga')),
            DataColumn(label: Text('Autori')),
            DataColumn(label: Text('Količina')),
            DataColumn(label: Text('Cijena')),
            DataColumn(label: Text('Kupac')),
            DataColumn(label: Text('Uposlenik')),
          ],
          rows: report.transactions.take(20).map((transaction) {
            return DataRow(
              cells: [
                DataCell(Text('${transaction.soldDate.day.toString().padLeft(2, '0')}.${transaction.soldDate.month.toString().padLeft(2, '0')}.${transaction.soldDate.year}')),
                DataCell(Text(transaction.bookTitle)),
                DataCell(Text(transaction.authorNames)),
                DataCell(Text(transaction.quantity.toString())),
                DataCell(Text('${transaction.totalPrice.toStringAsFixed(2)} KM')),
                DataCell(Text(transaction.customerName)),
                DataCell(Text(transaction.employeeName)),
              ],
            );
          }).toList(),
        ),
      );
    } else if (_currentReport is BooksRentedReport) {
      final report = _currentReport as BooksRentedReport;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Datum iznajmljivanja')),
            DataColumn(label: Text('Knjiga')),
            DataColumn(label: Text('Autori')),
            DataColumn(label: Text('Količina')),
            DataColumn(label: Text('Rok povrata')),
            DataColumn(label: Text('Kupac')),
            DataColumn(label: Text('Status')),
          ],
          rows: report.transactions.take(20).map((transaction) {
            String status = transaction.isReturned ? 'Vraćeno' : 
                           transaction.isOverdue ? 'Prekoračenje (${transaction.daysOverdue} dana)' : 'Aktivno';
            
            Color statusColor = transaction.isReturned ? Colors.green : 
                               transaction.isOverdue ? Colors.red : Colors.orange;

            return DataRow(
              cells: [
                DataCell(Text('${transaction.rentedDate.day.toString().padLeft(2, '0')}.${transaction.rentedDate.month.toString().padLeft(2, '0')}.${transaction.rentedDate.year}')),
                DataCell(Text(transaction.bookTitle)),
                DataCell(Text(transaction.authorNames)),
                DataCell(Text(transaction.quantity.toString())),
                DataCell(Text('${transaction.dueDate.day.toString().padLeft(2, '0')}.${transaction.dueDate.month.toString().padLeft(2, '0')}.${transaction.dueDate.year}')),
                DataCell(Text(transaction.customerName)),
                DataCell(Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w500))),
              ],
            );
          }).toList(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Januar', 'Februar', 'Mart', 'April', 'Maj', 'Juni',
      'Juli', 'August', 'Septembar', 'Oktobar', 'Novembar', 'Decembar'
    ];
    return monthNames[month - 1];
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      dynamic report;
      
      if (_selectedReportCategory == 'books_sold') {
        switch (_selectedReportType) {
          case 'custom':
            report = await _reportingService.getBooksSoldReport(
              startDate: _startDate,
              endDate: _endDate,
            );
            break;
          case 'month':
            report = await _reportingService.getBooksSoldReportByMonth(
              year: _selectedYear,
              month: _selectedMonth,
            );
            break;
          case 'quarter':
            report = await _reportingService.getBooksSoldReportByQuarter(
              year: _selectedYear,
              quarter: _selectedQuarter,
            );
            break;
          case 'year':
            report = await _reportingService.getBooksSoldReportByYear(
              year: _selectedYear,
            );
            break;
        }
      } else if (_selectedReportCategory == 'books_rented') {
        switch (_selectedReportType) {
          case 'custom':
            report = await _reportingService.getBooksRentedReport(
              startDate: _startDate,
              endDate: _endDate,
            );
            break;
          case 'month':
            report = await _reportingService.getBooksRentedReportByMonth(
              year: _selectedYear,
              month: _selectedMonth,
            );
            break;
          case 'quarter':
            report = await _reportingService.getBooksRentedReportByQuarter(
              year: _selectedYear,
              quarter: _selectedQuarter,
            );
            break;
          case 'year':
            report = await _reportingService.getBooksRentedReportByYear(
              year: _selectedYear,
            );
            break;
        }
      }
      
      setState(() {
        _currentReport = report;
        _isLoading = false;
      });
      
      if (report == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Greška pri generiranju izvještaja'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    try {
      if (_selectedReportCategory == 'books_sold') {
        switch (_selectedReportType) {
          case 'custom':
            await _reportingService.downloadBooksSoldPdfReport(
              startDate: _startDate,
              endDate: _endDate,
            );
            break;
          case 'month':
            await _reportingService.downloadBooksSoldPdfReportByMonth(
              year: _selectedYear,
              month: _selectedMonth,
            );
            break;
          case 'quarter':
            await _reportingService.downloadBooksSoldPdfReportByQuarter(
              year: _selectedYear,
              quarter: _selectedQuarter,
            );
            break;
          case 'year':
            await _reportingService.downloadBooksSoldPdfReportByYear(
              year: _selectedYear,
            );
            break;
        }
      } else if (_selectedReportCategory == 'books_rented') {
        switch (_selectedReportType) {
          case 'custom':
            await _reportingService.downloadBooksRentedPdfReport(
              startDate: _startDate,
              endDate: _endDate,
            );
            break;
          case 'month':
            await _reportingService.downloadBooksRentedPdfReportByMonth(
              year: _selectedYear,
              month: _selectedMonth,
            );
            break;
          case 'quarter':
            await _reportingService.downloadBooksRentedPdfReportByQuarter(
              year: _selectedYear,
              quarter: _selectedQuarter,
            );
            break;
          case 'year':
            await _reportingService.downloadBooksRentedPdfReportByYear(
              year: _selectedYear,
            );
            break;
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF izvještaj je preuzet'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri preuzimanju PDF-a: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 