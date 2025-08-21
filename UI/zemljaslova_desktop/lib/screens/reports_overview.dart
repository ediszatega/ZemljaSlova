import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../services/reporting_service.dart';
import '../models/reports/books_sold_report.dart';
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
                    child: BooksSoldReportsSection(),
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

class BooksSoldReportsSection extends StatefulWidget {
  const BooksSoldReportsSection({super.key});

  @override
  State<BooksSoldReportsSection> createState() => _BooksSoldReportsSectionState();
}

class _BooksSoldReportsSectionState extends State<BooksSoldReportsSection> {
  final ReportingService _reportingService = ReportingService(ApiService());
  
  BooksSoldReport? _currentReport;
  bool _isLoading = false;
  String _selectedReportType = 'custom';
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  int _selectedQuarter = 1;
  
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
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
        // Report Type Selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Izvještaj o prodaji knjiga',
                  style: TextStyle(
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
                    children: [
                      Expanded(
                          child: _buildSummaryCard(
                           'Ukupno prodanih knjiga',
                           _currentReport!.bookSummaries.length.toString(),
                           Icons.book,
                           Colors.blue,
                         ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Ukupan prihod',
                          '${_currentReport!.totalRevenue.toStringAsFixed(2)} KM',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Ukupno transakcija',
                          _currentReport!.totalTransactions.toString(),
                          Icons.receipt,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Book Summaries Table
                  if (_currentReport!.bookSummaries.isNotEmpty) ...[
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
                  if (_currentReport!.transactions.isNotEmpty) ...[
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
        rows: _currentReport!.bookSummaries.map((summary) {
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
  }

  Widget _buildTransactionsTable() {
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
        rows: _currentReport!.transactions.take(20).map((transaction) {
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
      BooksSoldReport? report;
      
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