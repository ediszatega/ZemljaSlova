import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'providers/navigation_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/book_provider.dart';
import 'providers/event_provider.dart';
import 'providers/favourite_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/member_provider.dart';
import 'providers/membership_provider.dart';
import 'providers/author_provider.dart';
import 'services/api_service.dart';
import 'services/book_service.dart';
import 'services/event_service.dart';
import 'services/favourite_service.dart';
import 'services/member_service.dart';
import 'services/membership_service.dart';
import 'services/author_service.dart';
import 'widgets/mobile_layout.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  try {
    Stripe.publishableKey = 'pk_test_51Rw80WA3p6s4oP6TdNagoydnF5ZnZ6tIGmRxLa0vez2IAFtRsByBsYQ9r17xZxTzCoLQ9xRLdnuuVa4w9MGmc0cV00IXyYyA65';
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint('Stripe initialization error in main.dart: $e');
  }
  
  runApp(const ZemljaSlova());
}

class ZemljaSlova extends StatelessWidget {
  const ZemljaSlova({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        ChangeNotifierProvider(create: (_) => AuthProvider(
          apiService: apiService, 
          isAdmin: false, // Mobile app is for members
        )),
        ChangeNotifierProvider(create: (context) => MobileNavigationProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(
          create: (context) => BookProvider(
            BookService(apiService),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => EventProvider(
            EventService(apiService),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FavouriteProvider(
            FavouriteService(apiService),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MemberProvider(
            memberService: MemberService(apiService: apiService),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MembershipProvider(
            membershipService: MembershipService(apiService: apiService),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthorProvider(
            AuthorService(apiService),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Zemlja slova',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90E2),
            brightness: Brightness.light,
          ),
          primaryColor: const Color(0xFF4A90E2),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const AuthenticationWrapper(),
      ),
    );
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
            ? const MobileLayout() 
            : const LoginScreen();
      },
    );
  }
}
