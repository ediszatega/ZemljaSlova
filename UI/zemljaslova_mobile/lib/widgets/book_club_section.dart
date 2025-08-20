import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_club_provider.dart';
import '../providers/member_provider.dart';
import '../screens/book_club_details_screen.dart';

class BookClubSection extends StatefulWidget {
  const BookClubSection({Key? key}) : super(key: key);

  @override
  State<BookClubSection> createState() => _BookClubSectionState();
}

class _BookClubSectionState extends State<BookClubSection> {
  @override
  void initState() {
    super.initState();
    _loadBookClubData();
  }

  void _loadBookClubData() {
    final memberProvider = context.read<MemberProvider>();
    final bookClubProvider = context.read<BookClubProvider>();
    
    if (memberProvider.currentMember != null) {
      bookClubProvider.loadCurrentYearData(memberProvider.currentMember!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookClubProvider, MemberProvider>(
      builder: (context, bookClubProvider, memberProvider, child) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookClubDetailsScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF28A745), Color(0xFF20C997)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Klub čitalaca',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pratite svoje bodove i aktivnosti',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (bookClubProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (bookClubProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Greška pri učitavanju podataka',
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    else
                     Container(
                       width: double.infinity,
                       child: _buildPointsCard(
                         'Bodovi ${bookClubProvider.currentYear}',
                         '${bookClubProvider.currentYearPoints}',
                         Icons.stars,
                         Colors.amber,
                       ),
                     ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28A745).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF28A745).withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF28A745),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Više detalja',
                          style: TextStyle(
                            color: Color(0xFF28A745),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
