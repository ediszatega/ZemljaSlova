import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/member_provider.dart';
import 'providers/book_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/members_overview.dart';
import 'screens/books_sell_overview.dart';
import 'screens/book_rent_overview.dart';
import 'screens/events_overview.dart';
import 'screens/reports_overview.dart';
import 'screens/profile_overview.dart';

void main() {
  runApp(const ZemljaSlova());
}

class ZemljaSlova extends StatelessWidget {
  const ZemljaSlova({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'Zemlja Slova',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3D5A80),
            primary: const Color(0xFF3D5A80),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        routes: {
          '/books-sell': (context) => const BooksSellOverview(),
          '/book-rent': (context) => const BookRentOverview(),
          '/events': (context) => const EventsOverview(),
          '/members': (context) => const MembersOverview(),
          '/reports': (context) => const ReportsOverview(),
          '/profile': (context) => const ProfileOverview(),
        },
        home: Consumer<NavigationProvider>(
          builder: (context, navigationProvider, child) {
            switch (navigationProvider.currentItem) {
              case NavigationItem.booksSell:
                return const BooksSellOverview();
              case NavigationItem.bookRent:
                return const BookRentOverview();
              case NavigationItem.events:
                return const EventsOverview();
              case NavigationItem.members:
                return const MembersOverview();
              case NavigationItem.reports:
                return const ReportsOverview();
              case NavigationItem.profile:
                return const ProfileOverview();
            }
          },
        ),
      ),
    );
  }
}
