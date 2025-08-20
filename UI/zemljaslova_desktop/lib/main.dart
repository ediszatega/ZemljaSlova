import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/member_provider.dart';
import 'providers/book_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/event_provider.dart';
import 'providers/author_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/user_provider.dart';
import 'providers/voucher_provider.dart';
import 'providers/discount_provider.dart';
import 'providers/membership_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/members_overview.dart';
import 'screens/books_sell_overview.dart';
import 'screens/books_rent_overview.dart';
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
import 'screens/vouchers_overview.dart';
import 'screens/discounts_overview.dart';
import 'screens/memberships_overview.dart';
import 'screens/discount_add.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/book_service.dart';
import 'services/author_service.dart';
import 'services/member_service.dart';
import 'services/event_service.dart';
import 'services/employee_service.dart';
import 'services/user_service.dart';
import 'services/voucher_service.dart';
import 'services/discount_service.dart';
import 'services/membership_service.dart';
import 'screens/book_club_leaderboard_screen.dart';

void main() {
  final apiService = ApiService();
  
  final bookService = BookService(apiService);
  final authorService = AuthorService(apiService);
  final memberService = MemberService(apiService);
  final eventService = EventService(apiService);
  final employeeService = EmployeeService(apiService);
  final userService = UserService(apiService);
  final voucherService = VoucherService(apiService);
  final discountService = DiscountService(apiService);
  final membershipService = MembershipService(apiService);
  
  runApp(
    ZemljaSlova(
      apiService: apiService,
      bookService: bookService,
      authorService: authorService,
      memberService: memberService,
      eventService: eventService,
      employeeService: employeeService,
      userService: userService,
      voucherService: voucherService,
      discountService: discountService,
      membershipService: membershipService,
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
  final VoucherService voucherService;
  final DiscountService discountService;
  final MembershipService membershipService;
  
  const ZemljaSlova({
    super.key,
    required this.apiService,
    required this.bookService,
    required this.authorService,
    required this.memberService,
    required this.eventService,
    required this.employeeService,
    required this.userService,
    required this.voucherService,
    required this.discountService,
    required this.membershipService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(
          apiService: apiService, 
          isAdmin: true, // Desktop app is for employees/admins
        )),
        ChangeNotifierProvider(create: (_) => MemberProvider(memberService)),
        ChangeNotifierProvider(create: (_) => BookProvider(bookService)),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider(eventService)),
        ChangeNotifierProvider(create: (_) => AuthorProvider(authorService)),
        ChangeNotifierProvider(create: (_) => EmployeeProvider(employeeService)),
        ChangeNotifierProvider(create: (_) => UserProvider(userService)),
        ChangeNotifierProvider(create: (_) => VoucherProvider(voucherService)),
        ChangeNotifierProvider(create: (_) => DiscountProvider(discountService)),
        ChangeNotifierProvider(create: (_) => MembershipProvider(membershipService)),
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
          '/book-rent': (context) => const BooksRentOverview(),
          '/events': (context) => const EventsOverview(),
          '/members': (context) => const MembersOverview(),
          '/memberships': (context) => const MembershipsOverview(),
          '/book-club': (context) => const BookClubLeaderboardScreen(),
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
          '/vouchers': (context) => const VouchersOverview(),
          '/discounts': (context) => const DiscountsOverview(),
          '/discount-add': (context) => const DiscountAddScreen(),
        },
        home: const AuthenticationWrapper(),
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
        return const BooksRentOverview();
      case NavigationItem.events:
        return const EventsOverview();
      case NavigationItem.members:
        return const MembersOverview();
      case NavigationItem.memberships:
        return const MembershipsOverview();
      case NavigationItem.bookClub:
        return const BookClubLeaderboardScreen();
      case NavigationItem.reports:
        return const ReportsOverview();
      case NavigationItem.profile:
        return const ProfileOverview();
      case NavigationItem.authors:
        return const AuthorsOverview();
      case NavigationItem.employees:
        return const EmployeesOverview();
      case NavigationItem.vouchers:
        return const VouchersOverview();
      case NavigationItem.discounts:
        return const DiscountsOverview();
    }
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: context.read<AuthProvider>().checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        bool isLoggedIn = snapshot.data ?? false;
        return isLoggedIn 
            ? const NavigationScreen() 
            : const LoginScreen();
      },
    );
  }
}
