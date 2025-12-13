import 'package:flutter/material.dart';
import 'login_screen.dart';

class DemoWrapper extends StatelessWidget {
  const DemoWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // For demo purposes, always show login screen
    // In real app, this would check authentication state
    return const LoginScreen();
  }
}