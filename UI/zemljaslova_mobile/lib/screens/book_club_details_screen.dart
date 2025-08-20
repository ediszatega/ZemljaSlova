import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_club_provider.dart';
import '../providers/member_provider.dart';

class BookClubDetailsScreen extends StatefulWidget {
  const BookClubDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BookClubDetailsScreen> createState() => _BookClubDetailsScreenState();
}

class _BookClubDetailsScreenState extends State<BookClubDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final memberProvider = context.read<MemberProvider>();
    final bookClubProvider = context.read<BookClubProvider>();
    
    if (memberProvider.currentMember != null) {
      bookClubProvider.refreshData(memberProvider.currentMember!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klub čitalaca'),
        backgroundColor: const Color(0xFF28A745),
        foregroundColor: Colors.white,
      ),
      body: Consumer2<BookClubProvider, MemberProvider>(
        builder: (context, bookClubProvider, memberProvider, child) {
          if (bookClubProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookClubProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    bookClubProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Pokušaj ponovo'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                   _buildHeader(),
                   const SizedBox(height: 24),
                   _buildPointsSystem(),
                   const SizedBox(height: 24),
                   _buildCurrentYearStats(bookClubProvider),
                   const SizedBox(height: 24),
                   _buildPreviousYearsStats(bookClubProvider),
                 ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF28A745), Color(0xFF20C997)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Klub čitalaca',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Dobrodošli u Klub čitalaca! Ovdje možete pratiti koliko bodova ste skupili u tekućoj godini, kao i pregled ranijih godina. Skupljanjem bodova ostvarujete šansu da ostvarite različite nagrade i pogodnosti. Na kraju godine uvijek nagrađujemo najaktivnije članove.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSystem() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: Colors.amber[600], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Sistem bodovanja',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPointsItem('Članarina', '50 bodova', Icons.card_membership),
            _buildPointsItem('Kupovina knjige', '30 bodova', Icons.book),
            _buildPointsItem('Iznajmljivanje knjige', '20 bodova', Icons.library_books),
            _buildPointsItem('Kupovina karte za događaj', '20 bodova', Icons.event),
            _buildPointsItem('Kupovina vaučera', '20 bodova', Icons.card_giftcard),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsItem(String title, String points, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF28A745), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF28A745),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              points,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentYearStats(BookClubProvider bookClubProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Bodovi ${bookClubProvider.currentYear}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
                         const SizedBox(height: 16),
             Container(
               width: double.infinity,
               child: _buildStatCard(
                 'Ukupno bodova',
                 '${bookClubProvider.currentYearPoints}',
                 Icons.stars,
                 Colors.amber,
               ),
             ),
             const SizedBox(height: 16),
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.blue[50],
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.blue[200]!),
               ),
               child: Row(
                 children: [
                   Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       'Kako biste vidjeli za šta ste dobili bodove pogledajte vašu historiju transakcija',
                       style: TextStyle(
                         color: Colors.blue[700],
                         fontSize: 14,
                         height: 1.4,
                       ),
                     ),
                   ),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

     Widget _buildStatCard(String title, String value, IconData icon, Color color) {
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: color.withOpacity(0.1),
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: color.withOpacity(0.3)),
       ),
       child: Column(
         children: [
           Icon(icon, color: color, size: 24),
           const SizedBox(height: 8),
           Text(
             value,
             style: TextStyle(
               fontSize: 24,
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

   Widget _buildPreviousYearsStats(BookClubProvider bookClubProvider) {
     final currentYear = DateTime.now().year;
     final previousYears = bookClubProvider.memberHistory
         ?.where((record) => record.year < currentYear)
         .toList() ?? [];

     return Card(
       elevation: 4,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       child: Padding(
         padding: const EdgeInsets.all(20),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               children: [
                 Icon(Icons.history, color: Colors.purple[600], size: 24),
                 const SizedBox(width: 8),
                 const Text(
                   'Bodovi u ranijim godina',
                   style: TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             if (previousYears.isEmpty)
               Column(
                 children: [
                   Icon(Icons.history, color: Colors.grey[400], size: 48),
                   const SizedBox(height: 16),
                   Text(
                     'Ovo je vaša prva godina u Klubu čitalaca!',
                     style: TextStyle(
                       fontSize: 14,
                       color: Colors.grey[500],
                     ),
                     textAlign: TextAlign.center,
                   ),
                 ],
               )
             else
               ...previousYears.map((record) => _buildYearRecord(record)),
           ],
         ),
       ),
     );
   }

   Widget _buildYearRecord(record) {
     return Container(
       margin: const EdgeInsets.only(bottom: 12),
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Colors.purple[50],
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: Colors.purple[200]!),
       ),
       child: Row(
         children: [
           Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: Colors.purple[100],
               borderRadius: BorderRadius.circular(8),
             ),
             child: Icon(
               Icons.calendar_today,
               color: Colors.purple[600],
               size: 20,
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   'Godina ${record.year}',
                   style: const TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 16,
                   ),
                 ),
                 const SizedBox(height: 4),
                 Text(
                   'Ukupno bodova: ${record.totalPoints}',
                   style: TextStyle(
                     color: Colors.grey[600],
                     fontSize: 14,
                   ),
                 ),
               ],
             ),
           ),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
             decoration: BoxDecoration(
               color: Colors.purple[600],
               borderRadius: BorderRadius.circular(16),
             ),
             child: Text(
               '${record.totalPoints}',
               style: const TextStyle(
                 color: Colors.white,
                 fontWeight: FontWeight.bold,
                 fontSize: 14,
               ),
             ),
           ),
         ],
       ),
     );
   }
 }
