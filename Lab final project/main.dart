import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/lock/lock_screen.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔔 Initialize local notifications
  await NotificationService.init();

  runApp(const FinovaApp());
}

class FinovaApp extends StatefulWidget {
  const FinovaApp({super.key});

  @override
  State<FinovaApp> createState() => _FinovaAppState();
}

class _FinovaAppState extends State<FinovaApp> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      // 🔐 LOCK FIRST → DASHBOARD AFTER UNLOCK
      home: _unlocked
          ? const DashboardScreen()
          : LockScreen(
        onUnlocked: () {
          setState(() => _unlocked = true);
        },
      ),
    );
  }
}
