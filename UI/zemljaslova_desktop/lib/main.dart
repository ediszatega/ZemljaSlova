import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/member_provider.dart';
import 'providers/book_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/event_provider.dart';
import 'providers/author_provider.dart';
import 'screens/members_overview.dart';
import 'screens/books_sell_overview.dart';
import 'screens/book_rent_overview.dart';
import 'screens/events_overview.dart';
import 'screens/reports_overview.dart';
import 'screens/profile_overview.dart';
import 'screens/authors_overview.dart';
import 'services/api_service.dart';
import 'services/book_service.dart';
import 'services/author_service.dart';

void main() {
  final apiService = ApiService();
  
  final bookService = BookService(apiService);
  final authorService = AuthorService(apiService);
  
  runApp(
    ZemljaSlova(
      apiService: apiService,
      bookService: bookService,
      authorService: authorService,
    ),
  );
}

class ZemljaSlova extends StatelessWidget {
  final ApiService apiService;
  final BookService bookService;
  final AuthorService authorService;
  
  const ZemljaSlova({
    super.key,
    required this.apiService,
    required this.bookService,
    required this.authorService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider(bookService)),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AuthorProvider(authorService)),
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
          '/authors': (context) => const AuthorsOverview(),
        },
        home: const NavigationScreen(),
      ),
    );
  }
}

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    
    return _buildCurrentScreen(navigationProvider.currentItem);
  }
  
  Widget _buildCurrentScreen(NavigationItem item) {
    switch (item) {
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
      case NavigationItem.authors:
        return const AuthorsOverview();
      default:
        return const MembersOverview();
    }
  }
}
