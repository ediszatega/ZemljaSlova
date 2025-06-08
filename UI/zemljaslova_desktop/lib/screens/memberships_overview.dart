import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/membership.dart';
import '../providers/membership_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/search_input.dart';
import '../widgets/empty_state.dart';
import 'membership_add.dart';

class MembershipsOverview extends StatefulWidget {
  const MembershipsOverview({super.key});

  @override
  State<MembershipsOverview> createState() => _MembershipsOverviewState();
}

class _MembershipsOverviewState extends State<MembershipsOverview> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MembershipProvider>(context, listen: false).fetchMemberships(includeMember: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  const Text(
                    'Pregled članarina',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Toolbar
                  _buildToolbar(),
                  
                  const SizedBox(height: 24),
                  
                  // Memberships table
                  Expanded(
                    child: _buildMembershipsTable(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search field
        Expanded(
          child: SearchInput(
            label: 'Pretraži',
            hintText: 'Pretraži članarine po članu',
            controller: _searchController,
            borderColor: Colors.grey.shade300,
            onChanged: (value) => _applyFilters(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Filter button
        ZSButton(
          onPressed: () {
            // TODO: Implement filter functionality
          },
          text: 'Postavi filtere',
          label: 'Filtriraj',
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
        
        const SizedBox(width: 16),
        
        // Add membership button
        ZSButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MembershipAddScreen()),
            );
          },
          text: 'Dodaj članarinu',
          backgroundColor: const Color(0xFFE5FFEE),
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
      ],
    );
  }

  Widget _buildMembershipsTable() {
    return Consumer<MembershipProvider>(
      builder: (context, membershipProvider, child) {
        if (membershipProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (membershipProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Greška: ${membershipProvider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ZSButton(
                  text: 'Pokušaj ponovo',
                  onPressed: () {
                    membershipProvider.fetchMemberships(includeMember: true);
                  },
                ),
              ],
            ),
          );
        }

        final memberships = _getFilteredMemberships(membershipProvider.memberships);

        if (memberships.isEmpty) {
          return const EmptyState(
            icon: Icons.card_membership,
            title: 'Nema članarina za prikaz',
            description: 'Trenutno nema zapisa o članarinama.\nKreirajte članarinu za korisnika.',
          );
        }

        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(50),   // Redni broj
                1: FlexColumnWidth(2),     // Član
                2: FixedColumnWidth(100),  // Datum početka
                3: FixedColumnWidth(100),  // Datum kraja
                4: FixedColumnWidth(90),   // Status
                5: FixedColumnWidth(90),   // Trajanje
                6: FixedColumnWidth(90),   // Preostalo dana
                7: FixedColumnWidth(140),  // Akcije
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  children: [
                    _buildTableHeader('Br.'),
                    _buildTableHeader('Član'),
                    _buildTableHeader('Početak'),
                    _buildTableHeader('Kraj'),
                    _buildTableHeader('Status'),
                    _buildTableHeader('Trajanje'),
                    _buildTableHeader('Preostalo'),
                    _buildTableHeader('Akcije'),
                  ],
                ),
                
                ...memberships.asMap().entries.map((entry) => _buildMembershipRow(entry.value, entry.key + 1)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  TableRow _buildMembershipRow(Membership membership, int orderNumber) {
    final isExpired = membership.isExpired;
    
    return TableRow(
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.shade50 : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      children: [
        _buildTableCell(orderNumber.toString()),
        _buildTableCell(membership.memberDisplay),
        _buildTableCell(_formatDate(membership.startDate)),
        _buildTableCell(_formatDate(membership.endDate)),
        _buildTableCell(
          membership.statusDisplay,
          color: isExpired ? Colors.red : (membership.isActive ? Colors.green : Colors.orange),
        ),
        _buildTableCell('${membership.durationInDays} dana'),
        _buildTableCell(
          isExpired ? '0 dana' : '${membership.daysRemaining} dana',
          color: membership.daysRemaining <= 7 && !isExpired ? Colors.orange : null,
        ),
        _buildActionsCell(membership),
      ],
    );
  }

  Widget _buildTableCell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionsCell(Membership membership) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _showDeleteDialog(membership),
            icon: const Icon(Icons.delete, size: 18),
            tooltip: 'Obriši',
            color: Colors.red,
          ),
          
          if (!membership.isExpired)
            IconButton(
              onPressed: () => _showEditDialog(membership),
              icon: const Icon(Icons.edit, size: 18),
              tooltip: 'Uredi',
              color: Colors.orange,
            ),
          
          IconButton(
            onPressed: () => _showMembershipDetails(membership),
            icon: const Icon(Icons.info, size: 18),
            tooltip: 'Detalji',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    final membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    
    membershipProvider.fetchMemberships(includeMember: true);
  }

  List<Membership> _getFilteredMemberships(List<Membership> memberships) {
    if (_searchController.text.isEmpty) {
      return memberships;
    }
    
    final searchTerm = _searchController.text.toLowerCase();
    return memberships.where((membership) {
      return membership.memberDisplay.toLowerCase().contains(searchTerm);
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  void _showDeleteDialog(Membership membership) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda brisanja'),
          content: Text(
            'Da li ste sigurni da želite obrisati članarinu za ${membership.memberDisplay}?\n\n'
            'Ova akcija se ne može poništiti.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await Provider.of<MembershipProvider>(context, listen: false)
                    .deleteMembership(membership.id);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Članarina je uspješno obrisana'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Greška pri brisanju članarine'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Membership membership) {
    final startDateController = TextEditingController(text: _formatDate(membership.startDate));
    final endDateController = TextEditingController(text: _formatDate(membership.endDate));
    DateTime selectedStartDate = membership.startDate;
    DateTime selectedEndDate = membership.endDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uredi članarinu - ${membership.memberDisplay}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startDateController,
                decoration: const InputDecoration(
                  labelText: 'Datum početka',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedStartDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    selectedStartDate = date;
                    startDateController.text = _formatDate(date);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(
                  labelText: 'Datum kraja',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedEndDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    selectedEndDate = date;
                    endDateController.text = _formatDate(date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await Provider.of<MembershipProvider>(context, listen: false)
                    .updateMembership(
                  membership.id,
                  startDate: selectedStartDate,
                  endDate: selectedEndDate,
                );
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Članarina je uspješno ažurirana'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Greška pri ažuriranju članarine'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Sačuvaj'),
            ),
          ],
        );
      },
    );
  }

  void _showMembershipDetails(Membership membership) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalji članarine - ${membership.memberDisplay}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID:', membership.id.toString()),
              _buildDetailRow('Član:', membership.memberDisplay),
              _buildDetailRow('Datum početka:', _formatDate(membership.startDate)),
              _buildDetailRow('Datum kraja:', _formatDate(membership.endDate)),
              _buildDetailRow('Status:', membership.statusDisplay),
              _buildDetailRow('Trajanje:', '${membership.durationInDays} dana'),
              if (!membership.isExpired)
                _buildDetailRow('Preostalo:', '${membership.daysRemaining} dana'),
              if (membership.member != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Informacije o članu:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Email:', membership.member!.email),
                _buildDetailRow('Datum rođenja:', _formatDate(membership.member!.dateOfBirth)),
                _buildDetailRow('Datum učlanjenja:', _formatDate(membership.member!.joinedAt)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zatvori'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 