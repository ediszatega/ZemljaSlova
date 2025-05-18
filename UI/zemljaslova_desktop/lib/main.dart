import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/member_provider.dart';
import 'providers/book_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/event_provider.dart';
import 'providers/author_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/user_provider.dart';
import 'screens/members_overview.dart';
import 'screens/books_sell_overview.dart';
import 'screens/book_rent_overview.dart';
import 'screens/events_overview.dart';
import 'screens/reports_overview.dart';
import 'screens/profile_overview.dart';
import 'screens/authors_overview.dart';
import 'screens/author_add.dart';
import 'screens/book_add.dart';
import 'screens/event_add.dart';
import 'screens/event_edit.dart';
import 'screens/member_add.dart';
import 'screens/member_edit.dart';
import 'screens/employees_overview.dart';
import 'screens/employee_add.dart';
import 'screens/employee_edit.dart';
import 'services/api_service.dart';
import 'services/book_service.dart';
import 'services/author_service.dart';
import 'services/member_service.dart';
import 'services/event_service.dart';
import 'services/employee_service.dart';
import 'services/user_service.dart';

void main() {
  final apiService = ApiService();
  
  final bookService = BookService(apiService);
  final authorService = AuthorService(apiService);
  final memberService = MemberService(apiService);
  final eventService = EventService(apiService);
  final employeeService = EmployeeService(apiService);
  final userService = UserService(apiService);
  
  runApp(
    ZemljaSlova(
      apiService: apiService,
      bookService: bookService,
      authorService: authorService,
      memberService: memberService,
      eventService: eventService,
      employeeService: employeeService,
      userService: userService,
    ),
  );
}

class ZemljaSlova extends StatelessWidget {
  final ApiService apiService;
  final BookService bookService;
  final AuthorService authorService;
  final MemberService memberService;
  final EventService eventService;
  final EmployeeService employeeService;
  final UserService userService;
  
  const ZemljaSlova({
    super.key,
    required this.apiService,
    required this.bookService,
    required this.authorService,
    required this.memberService,
    required this.eventService,
    required this.employeeService,
    required this.userService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemberProvider(memberService)),
        ChangeNotifierProvider(create: (_) => BookProvider(bookService)),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider(eventService)),
        ChangeNotifierProvider(create: (_) => AuthorProvider(authorService)),
        ChangeNotifierProvider(create: (_) => EmployeeProvider(employeeService)),
        ChangeNotifierProvider(create: (_) => UserProvider(userService)),
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
          '/author-add': (context) => const AuthorAddScreen(),
          '/book-add': (context) => const BookAddScreen(),
          '/event-add': (context) => const EventAddScreen(),
          '/event-edit': (context) => const EventEditScreen(eventId: 0),
          '/member-add': (context) => const MemberAddScreen(),
          '/member-edit': (context) => const MemberEditScreen(memberId: 0),
          '/employees': (context) => const EmployeesOverview(),
          '/employee-add': (context) => const EmployeeAddScreen(),
          '/employee-edit': (context) => const EmployeeEditScreen(employeeId: 0),
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
      case NavigationItem.employees:
        return const EmployeesOverview();
      default:
        return const MembersOverview();
    }
  }
}
