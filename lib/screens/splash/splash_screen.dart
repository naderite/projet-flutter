import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import '../../theme/app_colors.dart';
import '../auth/auth_screen.dart';

/// SplashScreen shows an animated GIF (assets/splash.gif) while Firebase
/// initializes, then navigates to the AuthScreen. Keep the GIF file in
/// `assets/splash.gif` to have it animate. Native launch screen will show
/// the solid background until Flutter draws the first frame.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _ready = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Show the splash for at least a short duration so the GIF is visible.
    final minDelay = Future.delayed(const Duration(milliseconds: 1500));
    try {
      // Check if Firebase is already initialized (e.g., by native google-services plugin)
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initError = null;
    } catch (e, st) {
      _initError = e.toString();
      // ignore: avoid_print
      print('Firebase.initializeApp() failed: $e\n$st');
    }
    await minDelay;
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      if (_initError != null) {
        return _buildErrorScreen();
      }
      return const AuthScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/splash.gif',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Firebase initialization failed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _initError ?? 'Unknown error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _ready = false;
                      _initError = null;
                    });
                    await _init();
                  },
                  child: const Text('Retry Initialize Firebase'),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'On web make sure you configured Firebase with FirebaseOptions (see README).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
