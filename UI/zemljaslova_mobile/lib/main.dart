import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/book_provider.dart';
import 'providers/event_provider.dart';
import 'providers/favourite_provider.dart';
import 'services/api_service.dart';
import 'services/book_service.dart';
import 'services/event_service.dart';
import 'services/favourite_service.dart';
import 'widgets/mobile_layout.dart';

void main() {
  runApp(const ZemljaSlova());
}

class ZemljaSlova extends StatelessWidget {
  const ZemljaSlova({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MobileNavigationProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(
          create: (context) => BookProvider(
            BookService(ApiService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => EventProvider(
            EventService(ApiService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FavouriteProvider(
            FavouriteService(ApiService()),
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
        ),
        home: const MobileLayout(),
      ),
    );
  }
}
