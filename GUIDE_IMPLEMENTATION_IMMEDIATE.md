# 🚀 Guide d'Implémentation Immédiate – LinguaPlay

**Objectif** : Implémenter étape par étape les éléments critiques pour MVP en 4 semaines.

---

## 1️⃣ Créer les modèles complets (1-2 jours)

### Étape 1.1 : `lib/models/game_models.dart`

```dart
import '../screens/utils/constants.dart';

class Language {
  final int id;
  final String name;
  final String code;
  final String? flagIcon;

  Language({
    required this.id,
    required this.name,
    required this.code,
    this.flagIcon,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      code: json['code'] ?? '',
      flagIcon: json['flag_icon'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'flag_icon': flagIcon,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Game {
  final int id;
  final String title;
  final String description;
  final String gameType; // QUIZ, MEMORY, WORD_SEARCH, LISTENING
  final int difficulty; // 1-5
  final Language language;
  final bool isExternal;
  final String? externalUrl;

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.gameType,
    required this.difficulty,
    required this.language,
    required this.isExternal,
    this.externalUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      gameType: json['game_type'] ?? 'QUIZ',
      difficulty: json['difficulty'] ?? 1,
      language: Language.fromJson(json['language'] ?? {}),
      isExternal: json['is_external'] ?? false,
      externalUrl: json['external_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'game_type': gameType,
    'difficulty': difficulty,
    'language_id': language.id,
    'is_external': isExternal,
    'external_url': externalUrl,
  };

  String get difficultyLabel {
    final labels = ['Easy', 'Medium', 'Hard', 'Expert', 'Legendary'];
    return labels[difficulty - 1];
  }

  String get gameTypeLabel {
    const labels = {
      'QUIZ': 'Quiz',
      'MEMORY': 'Memory Game',
      'WORD_SEARCH': 'Word Search',
      'LISTENING': 'Listening',
    };
    return labels[gameType] ?? gameType;
  }
}

class GameSession {
  final int id;
  final int userId;
  final int gameId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double? score;

  GameSession({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.startedAt,
    this.completedAt,
    this.score,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] ?? 0,
      userId: json['user'] ?? 0,
      gameId: json['game'] ?? 0,
      startedAt: DateTime.parse(json['started_at'] ?? DateTime.now().toString()),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      score: json['score']?.toDouble(),
    );
  }

  bool get isCompleted => completedAt != null;
  Duration? get duration => completedAt != null
      ? completedAt!.difference(startedAt)
      : null;
}

class QuizQuestion {
  final int id;
  final String question;
  final List<String> answers;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswerIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answers: List<String>.from(json['answers'] ?? []),
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
    );
  }

  bool isCorrect(int selectedIndex) => selectedIndex == correctAnswerIndex;
}
```

### Étape 1.2 : `lib/models/challenge_models.dart`

```dart
class Challenge {
  final int id;
  final String title;
  final String description;
  final Map<String, dynamic> language;
  final int pointsReward;
  final bool isDaily;
  final DateTime startDate;
  final DateTime endDate;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.pointsReward,
    required this.isDaily,
    required this.startDate,
    required this.endDate,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Challenge',
      description: json['description'] ?? '',
      language: json['language'] ?? {},
      pointsReward: json['points_reward'] ?? 10,
      isDaily: json['is_daily'] ?? false,
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toString()),
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  Duration? get timeRemaining {
    if (!isActive) return null;
    return endDate.difference(DateTime.now());
  }
}

class UserChallengeProgress {
  final int id;
  final int userId;
  final int challengeId;
  final bool isCompleted;
  final DateTime? completionDate;

  UserChallengeProgress({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.isCompleted,
    this.completionDate,
  });

  factory UserChallengeProgress.fromJson(Map<String, dynamic> json) {
    return UserChallengeProgress(
      id: json['id'] ?? 0,
      userId: json['user'] ?? 0,
      challengeId: json['challenge'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
    );
  }
}
```

### Étape 1.3 : `lib/models/profile_models.dart`

Remplacer le fichier vide par :

```dart
import 'game_models.dart';

class UserProfile {
  final int id;
  final Map<String, dynamic> user; // {id, username, email}
  final List<Language> languagesLearning;
  final int currentStreak;
  final int totalPoints;
  final String? avatar;

  UserProfile({
    required this.id,
    required this.user,
    required this.languagesLearning,
    required this.currentStreak,
    required this.totalPoints,
    this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      user: json['user'] ?? {},
      languagesLearning: (json['languages_learning'] as List?)
          ?.map((lang) => Language.fromJson(lang))
          .toList() ?? [],
      currentStreak: json['current_streak'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() => {
    'languages_learning_ids': languagesLearning.map((l) => l.id).toList(),
    'current_streak': currentStreak,
    'total_points': totalPoints,
  };

  String get username => user['username'] ?? 'Guest';
  String get email => user['email'] ?? '';
}
```

### Étape 1.4 : `lib/models/reward_models.dart`

Remplacer le fichier vide par :

```dart
class Reward {
  final int id;
  final String name;
  final String description;
  final String icon; // Emoji ou URI
  final int pointsRequired;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.pointsRequired,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Badge',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      pointsRequired: json['points_required'] ?? 0,
    );
  }
}

class UserReward {
  final int id;
  final int userId;
  final int rewardId;
  final DateTime unlockedAt;

  UserReward({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.unlockedAt,
  });

  factory UserReward.fromJson(Map<String, dynamic> json) {
    return UserReward(
      id: json['id'] ?? 0,
      userId: json['user'] ?? 0,
      rewardId: json['reward'] ?? 0,
      unlockedAt: DateTime.parse(json['unlocked_at'] ?? DateTime.now().toString()),
    );
  }
}
```

---

## 2️⃣ Mettre à jour ApiService (2-3 jours)

Remplacer `lib/services/api_service.dart` par la version complète du rapport.

**Points clés** :
- ✅ Endpoints authentifiés avec token
- ✅ Gestion erreurs standardisée
- ✅ Methods pour games, challenges, profiles, rewards
- ✅ Pagination support

---

## 3️⃣ Créer ProfileProvider (1 jour)

Créer `lib/providers/profile_provider.dart` (code dans rapport).

**Fonctionnalités** :
- Charger profil utilisateur (`/profiles/my_profile/`)
- Mettre à jour profil
- Sélectionner langues d'apprentissage
- Tracker points et streak

---

## 4️⃣ Créer GameProvider (1 jour)

Créer `lib/providers/game_provider.dart` (code dans rapport).

**Fonctionnalités** :
- Charger liste jeux (avec filtres)
- Démarrer session jeu
- Terminer jeu avec score
- Tracker session courante

---

## 5️⃣ Créer ChallengeProvider (1 jour)

Créer `lib/providers/challenge_provider.dart` (code dans rapport).

**Fonctionnalités** :
- Charger défis actifs
- Charger défi du jour
- Marquer défi comme complété

---

## 6️⃣ Améliorer AuthProvider (1 jour)

Mettre à jour `lib/providers/auth_provider.dart` pour appeler ApiService réel.

```dart
class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  AuthProvider(this._apiService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequest(username: username, password: password);
      final user = await _apiService.login(request);
      _user = user;
      _isAuthenticated = true;
      
      // Sauvegarder token
      if (user.token != null) {
        _apiService.setAuthToken(user.token!);
        await _saveToken(user.token!);
      }
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
      );
      final user = await _apiService.register(request);
      _user = user;
      _isAuthenticated = true;
      
      if (user.token != null) {
        _apiService.setAuthToken(user.token!);
        await _saveToken(user.token!);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    // Implémenter avec flutter_secure_storage
    // await _storage.write(key: 'auth_token', value: token);
  }
}
```

---

## 7️⃣ Créer OnboardingScreen (2 jours)

Créer `lib/screens/onboarding/onboarding_screen.dart`.

**Contenu** :
- 3 écrans (Bienvenue, Sélection langue, Confirmation)
- PageView avec indicateurs
- Navigation vers HomeScreen après

```dart
// Exemple structure
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() => _currentPage = page);
        },
        children: [
          _buildWelcomePage(),
          _buildLanguageSelectionPage(),
          _buildConfirmationPage(),
        ],
      ),
    );
  }
}
```

---

## 8️⃣ Créer GamesListScreen (2 jours)

Créer `lib/screens/games/games_list_screen.dart`.

**Contenu** :
- GridView des jeux disponibles
- Filtres (difficulté, langue)
- Recherche
- Tap = lance QuizScreen

---

## 9️⃣ Créer QuizScreen (3 jours)

Créer `lib/screens/games/quiz_screen.dart`.

**Contenu** :
- Question + 4 boutons réponses
- Timer
- Score tracker
- Feedback correct/incorrect
- Submit résultat → GameResultScreen

```dart
// Pseudo-structure
class QuizScreen extends StatefulWidget {
  final Game game;

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  late Timer _timer;
  int _secondsRemaining = 60;

  void _answerQuestion(int answerIndex) {
    // Vérifier réponse
    // Incrémenter score
    // Aller question suivante
    setState(() {
      _currentQuestionIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.game.title)),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _currentQuestionIndex / 10, // Supposer 10 questions
          ),
          SizedBox(height: 20),
          Text(_secondsRemaining.toString()),
          Expanded(
            child: QuestionWidget(
              question: _questions[_currentQuestionIndex],
              onAnswerSelected: _answerQuestion,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔟 Créer ProfileScreen (2 jours)

Créer `lib/screens/profile/profile_screen.dart`.

**Contenu** :
- Avatar utilisateur
- Points + Streak
- Langues sélectionnées
- Bouton éditer profil
- Historique jeux récents
- Bouton paramètres

---

## Mise à jour pubspec.yaml

Ajouter dépendances manquantes :

```yaml
dependencies:
  # State Management
  provider: ^6.1.1
  
  # Networking
  http: ^1.1.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # UI
  google_fonts: ^6.1.0
  intl: ^0.19.0
  confetti: ^0.7.0
  
  # Navigation (optionnel pour Phase 1)
  go_router: ^14.0.0
```

Puis : `flutter pub get`

---

## Checklist Implémentation Semaine 1

- [ ] Modèles game_models.dart
- [ ] Modèles challenge_models.dart
- [ ] Modèles profile_models.dart
- [ ] Modèles reward_models.dart
- [ ] ApiService complet
- [ ] ProfileProvider
- [ ] GameProvider
- [ ] ChallengeProvider
- [ ] AuthProvider amélioré
- [ ] pubspec.yaml mis à jour
- [ ] flutter analyze ✅
- [ ] Tests unitaires modèles

## Checklist Implémentation Semaine 2

- [ ] OnboardingScreen + LanguageSelectionScreen
- [ ] GamesListScreen
- [ ] QuizScreen basique
- [ ] GameResultScreen
- [ ] ProfileScreen
- [ ] Intégration providers dans écrans
- [ ] Error handling UI
- [ ] Loading states
- [ ] Navigation entre écrans
- [ ] Tests widgets
- [ ] Beta testing interne

---

## Problèmes courants et solutions

### ❌ Erreur : "Token not found"
→ Vérifier que token est sauvegardé après login  
→ Vérifier que `ApiService.setAuthToken()` est appelé

### ❌ Erreur : "Failed to load games"
→ Vérifier que backend tourne sur `localhost:8000`  
→ Vérifier `CORS` settings dans Django (django-cors-headers)

### ❌ Écran blanc après navigation
→ Utiliser `FutureBuilder` + `Consumer<XProvider>` pour charger données  
→ Ajouter `if (!mounted) return;` après `await`

### ❌ Memory leak dans Provider
→ Toujours appeler `super.dispose()` dans `_State.dispose()`  
→ Utiliser `listen: false` quand updater state sans rebuild

---

## Prochaines étapes après Semaine 2

1. User testing avec beta testers
2. Collecte feedback UI/UX
3. Optimisations performance
4. Intégration Firebase Analytics
5. Préparation App Store/Play Store

