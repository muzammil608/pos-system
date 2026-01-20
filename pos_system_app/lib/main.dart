import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'screens/login_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/receipt_screen.dart';
import 'screens/kitchen_screen.dart';
import 'screens/admin_screen.dart';

void main() {
  runApp(PosApp());
}

class PosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF2F3F7),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF5B2D8B),
            foregroundColor: Colors.white,
          ),
        ),
        routes: {
          '/login': (_) => LoginScreen(),
          '/pos': (_) => PosScreen(),
          '/receipt': (_) => ReceiptScreen(),
          '/kitchen': (_) => KitchenScreen(),
          '/admin': (_) => AdminScreen(),
        },
      ),
    );
  }
}
