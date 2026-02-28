import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';

import 'screens/login_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/receipt_screen.dart';
import 'screens/kitchen_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF2F3F7),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF5B2D8B),
            foregroundColor: Colors.white,
          ),
        ),
        home: const AuthWrapper(), // 🔥 IMPORTANT CHANGE
        routes: {
          '/login': (_) => const LoginScreen(),
          '/pos': (_) => const PosScreen(),
          '/receipt': (_) => const ReceiptScreen(),
          '/kitchen': (_) => const KitchenScreen(),
          '/admin': (_) => const AdminScreen(),
        },
      ),
    );
  }
}

/// ================= AUTH WRAPPER =================
/// This decides where to go automatically
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AuthProvider>(context, listen: false).checkCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Still checking session
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Not logged in
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    // Logged in → check role
    if (auth.isAdmin) {
      return const AdminScreen();
    }

    return const PosScreen();
  }
}
