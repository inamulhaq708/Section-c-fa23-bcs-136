import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _message = 'Authenticate to continue';

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final bool canCheck = await _auth.canCheckBiometrics;

      if (!canCheck) {
        setState(() {
          _message = 'No biometric available on this device';
        });
        return;
      }

      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Unlock Finova using fingerprint or face',
        options: const AuthenticationOptions(
          biometricOnly: false, // allows PIN / pattern fallback
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        widget.onUnlocked();
      }
    } catch (e) {
      setState(() => _message = 'Authentication failed');
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint,
                size: 90, color: Colors.indigo),
            const SizedBox(height: 16),
            Text(
              _message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _authenticate,
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
