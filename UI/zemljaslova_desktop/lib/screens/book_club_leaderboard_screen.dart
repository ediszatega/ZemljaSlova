import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/book_club_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';

class BookClubLeaderboardScreen extends StatefulWidget {
  const BookClubLeaderboardScreen({super.key});

  @override
  State<BookClubLeaderboardScreen> createState() => _BookClubLeaderboardScreenState();
}

class _BookClubLeaderboardScreenState extends State<BookClubLeaderboardScreen> {
  final List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMoreData = true;
  late BookClubService _bookClubService;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<AuthProvider>(context, listen: false).apiService;
    _bookClubService = BookClubService(apiService: apiService);
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _leaderboard.clear();
        _hasMoreData = true;
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
      final response = await _bookClubService.getLeaderboard(
        page: _currentPage,
        pageSize: 20,
      );

      if (response != null && response['members'] is List) {
        final newEntries = (response['members'] as List).map((member) {
          return {
            'rank': member['rank'] ?? 0,
            'memberId': member['memberId'] ?? 0,
            'memberName': member['memberName'] ?? 'Nepoznato',
            'points': member['points'] ?? 0,
            'email': member['email'] ?? '',
          };
        }).toList();

        setState(() {
          if (refresh) {
            _leaderboard.clear();
          }
          _leaderboard.addAll(newEntries);
          _totalCount = response['totalCount'] ?? newEntries.length;
          _currentPage++;
          _hasMoreData = _leaderboard.length < _totalCount;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Greška pri učitavanju podataka';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Greška pri učitavanju podataka: $e';
        _isLoading = false;
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 44, left: 80.0, right: 80.0, bottom: 44.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Klub čitalaca - Rang lista',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rang lista članova prema bodovima za ${DateTime.now().year}. godinu',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Leaderboard
                    _buildLeaderboard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    if (_isLoading && _leaderboard.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null && _leaderboard.isEmpty) {
      return Center(
        child: Column(
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ZSButton(
              text: 'Pokušaj ponovo',
              onPressed: () => _loadLeaderboard(refresh: true),
            ),
          ],
        ),
      );
    }

    if (_leaderboard.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Nema dostupnih podataka za rang listu.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Leaderboard table
        Container(
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
          child: Column(
            children: [
              // Table header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        'Rang',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Član',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        'Bodovi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table rows
              ..._leaderboard.map((entry) => _buildLeaderboardRow(entry)).toList(),
            ],
          ),
        ),

        // Load more button
        if (_hasMoreData)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ZSButton(
                text: 'Učitaj više',
                onPressed: _isLoading ? () {} : () => _loadLeaderboard(),
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
              ),
            ),
          ),

        // Loading indicator
        if (_isLoading && _leaderboard.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildLeaderboardRow(Map<String, dynamic> entry) {
    final isTopThree = entry['rank'] <= 3;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  if (isTopThree) ...[
                    Icon(
                      _getRankIcon(entry['rank']),
                      color: _getRankColor(entry['rank']),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '${entry['rank']}.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isTopThree ? _getRankColor(entry['rank']) : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Member name
            Expanded(
              flex: 3,
              child: Text(
                entry['memberName'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Email
            Expanded(
              flex: 2,
              child: Text(
                entry['email'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            // Points
            SizedBox(
              width: 120,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Text(
                  '${entry['points']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Gold
      case 2:
        return Icons.military_tech; // Silver
      case 3:
        return Icons.workspace_premium; // Bronze
      default:
        return Icons.star;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600; // Gold
      case 2:
        return Colors.grey.shade500; // Silver
      case 3:
        return Colors.orange.shade600; // Bronze
      default:
        return Colors.grey.shade400;
    }
  }
}
