import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/challenge_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/reward_provider.dart';
import 'providers/social_provider.dart';
import 'providers/xp_provider.dart';
import 'providers/content_provider.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/home_screen_duolingo.dart';
import 'screens/games/games_list_screen.dart';
import 'screens/games/quiz_screen.dart';
import 'screens/games/memory_game_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/result_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/language_setup_screen.dart';
import 'screens/utils/constants.dart';
import 'screens/utils/themes.dart';
import 'reset_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await resetAuth();
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Service pour les appels API
        Provider<ApiService>(create: (_) => ApiService()),
        
        // Providers pour la gestion d'état
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => GameProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChallengeProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RewardProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SocialProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => XPProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ContentProvider(),
        ),
      ],
        child: MaterialApp(
        title: AppStrings.appName,
        theme: AppThemes.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreenDuolingo(),
          '/games': (context) => const GamesListScreen(),
          '/quiz': (context) => const QuizScreen(),
          '/memory': (context) => const MemoryGameScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/language-selection': (context) => const LanguageSelectionScreen(),
          '/language-setup': (context) => const LanguageSetupScreen(),
          '/result': (context) => const ResultScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          '/stats': (context) => const StatsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Widget wrapper pour vérifier l'authentification au démarrage
class _HomePageWrapper extends StatefulWidget {
  const _HomePageWrapper();

  @override
  State<_HomePageWrapper> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<_HomePageWrapper> {
  @override
  void initState() {
    super.initState();
    // Vérifier si l'utilisateur est déjà connecté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}