import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import 'onboarding_duolingo_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 1400));

    // Check authentication status first
    final auth = context.read<AuthProvider>();
    await auth.checkAuthStatus();
    
    if (!mounted) return;
    
    // Load persisted language selection into GameProvider before navigating
    try {
      final gp = context.read<GameProvider>();
      final persisted = await gp.loadPersistedSelectedLanguages();
      if (persisted.isNotEmpty) {
        await gp.loadGamesByLanguage(persisted.first);
      }
    } catch (_) {}
    
    if (!mounted) return;
    
    if (auth.isAuthenticated) {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool('language_setup_complete') ?? false;
      Navigator.pushReplacementNamed(context, completed ? '/home' : '/language-setup');
    } else {
      // Show onboarding first (which will lead to login/register)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingDuolingoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A86FF), Color(0xFF83C5BE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                // Logo centered (120x120px)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.language,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                // App name
                const Text(
                  '🌍 LinguaPlay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Tagline
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    '"Learn Languages\nin a Fun Way!"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                // Loading spinner
                const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
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
