# 📱 Rapport d'Analyse et Propositions d'Améliorations – LinguaPlay

**Date** : 22 novembre 2025  
**Projet** : LinguaPlay (Application d'apprentissage des langues)  
**Contexte** : Analyse de la conformité code Flutter vs cahier des charges  
**Backend** : Django REST Framework (API complète existante)  

---

## 📋 Table des matières

1. [État actuel du projet](#état-actuel)
2. [Écarts identifiés vs cahier des charges](#écarts-identifiés)
3. [Architecture proposée](#architecture-proposée)
4. [Modèles de données (Flutter)](#modèles-flutter)
5. [Providers (State Management)](#providers)
6. [Services et API](#services-api)
7. [Écrans à développer](#écrans-à-développer)
8. [Recommandations design (Figma)](#recommandations-design)
9. [Roadmap d'implémentation](#roadmap)

---

## État actuel du projet {#état-actuel}

### ✅ Existant

#### Frontend (Flutter)
- ✅ **Authentification** : Écran login + register (basique)
- ✅ **Linting** : Zéro erreur après corrections (flutter analyze clean)
- ✅ **Widgets** : CustomButton, CustomTextField prêts
- ✅ **Modèles** : User (login/register) partiellement implémenté
- ✅ **Services** : ApiService (stub), storage_service placé
- ✅ **Provider** : AuthProvider (simulation)
- ✅ **Home screen** : Squelette avec défis du jour

#### Backend (Django REST)
- ✅ **Modèles** : Language, Game, UserProfile, Challenge, UserChallengeProgress, Reward, UserGameSession
- ✅ **API REST** : Endpoints complets avec DjangoFilterBackend, search, ordering
- ✅ **ViewSets** : GameViewSet, ChallengeViewSet, UserProfileViewSet
- ✅ **Actions personnalisées** : active_challenges, complete_challenge, leaderboard, daily_challenge
- ✅ **Sécurité** : TokenAuthentication, IsAuthenticated permissions
- ✅ **Media** : Gestion des avatars (upload to 'avatars/')

### ❌ Manquant ou incomplet

#### Frontend
- ❌ **Modèles complets** : Game, Challenge, Reward, UserProfile, UserGameSession (vides ou incomplets)
- ❌ **Providers** : GameProvider, ChallengeProvider, ProfileProvider, RewardProvider (absents)
- ❌ **Services réels** : ApiService ne appelle pas vraiment le backend (hardcodé)
- ❌ **Écrans de jeu** : Quiz, Memory, Word Search, Listening (aucun écran implémenté)
- ❌ **Dashboard complet** : Statistiques, classement, récompenses (squelette seulement)
- ❌ **Profil utilisateur** : Édition, sélection langue, avatar (absent)
- ❌ **Défis** : Affichage, interaction avec les défis journaliers (absent)
- ❌ **Social** : Partage, inviter amis, reyting (absent)
- ❌ **Admin** : Gestion contenu (hors scope mobile, mais API existe)
- ❌ **Responsive design** : Pas d'optimisation desktop (cahier demande mobile + desktop)
- ❌ **Notifications** : Push notifications (absent)
- ❌ **Offline mode** : Sync local (absent)

---

## Écarts identifiés vs cahier des charges {#écarts-identifiés}

### 1. **Authentification** 
- **Requis** : 2FA, récupération mot de passe, OAuth social
- **Existant** : Login/Register basique
- **Action** : Ajouter endpoints backend pour 2FA, récupération pwd; implémenter UI

### 2. **Sélection langue et onboarding**
- **Requis** : Écran de sélection langue (US2), tutoriel interactif
- **Existant** : Rien
- **Action** : Créer écran LanguageSelectionScreen + OnboardingScreen

### 3. **Jeux éducatifs**
- **Requis** : Quiz, Memory, Word Search, Listening Comprehension (US1)
- **Existant** : Modèle Game vide dans Flutter
- **Action** : Implémenter 4 écrans de jeu + GameProvider + intégration API

### 4. **Défis journaliers**
- **Requis** : Affichage défi du jour, notifications, récompenses (US3)
- **Existant** : Squelette dans HomeScreen
- **Action** : Créer ChallengeProvider, intégrer /daily-challenge/ endpoint

### 5. **Profil et statistiques**
- **Requis** : Dashboard progression, historique, sélection avatar (US4)
- **Existant** : Rien
- **Action** : ProfileScreen + ProfileProvider, appeler /profiles/my_profile/

### 6. **Système de récompenses**
- **Requis** : Badges, niveaux, reyting (US6)
- **Existant** : Modèle Reward au backend, absent du Flutter
- **Action** : RewardProvider, RewardScreen, animations (confetti)

### 7. **Fonctionnalités sociales**
- **Requis** : Défi amis, partage résultats, classement (US5)
- **Existant** : API leaderboard existe, absent du Flutter
- **Action** : FriendsScreen, LeaderboardScreen, ShareProvider

### 8. **Gestion multiculturelle**
- **Requis** : Support multilingue, contenu culturel
- **Existant** : Rien
- **Action** : Intégrer l10n (intl), ajouter contenu culturel (AppThemes déjà prêt)

### 9. **Responsive design**
- **Requis** : Mobile + Desktop (cahier section 6)
- **Existant** : Code mobile seulement
- **Action** : Adapter avec MediaQuery, créer layouts desktop alternatifs

### 10. **Performance et offline**
- **Requis** : <3s chargement initial, cache local
- **Existant** : Pas d'optimisation, pas de cache
- **Action** : Implémenter Hive/SQLite pour cache, image optimization

---

## Architecture proposée {#architecture-proposée}

```
linguaplay_app/
├── lib/
│   ├── main.dart                    # Entrée + RouterDelegate (Go Router)
│   ├── config/                      # Configuration globale
│   │   ├── api_config.dart         # Constantes API, endpoints
│   │   ├── theme_config.dart       # Thème unifié (Material 3)
│   │   └── l10n/                   # i18n (français, anglais, espagnol)
│   │       ├── app_fr.arb
│   │       ├── app_en.arb
│   │       └── app_es.arb
│   │
│   ├── models/
│   │   ├── auth_models.dart        # User, LoginRequest, RegisterRequest
│   │   ├── game_models.dart        # Game, GameSession, Answer
│   │   ├── challenge_models.dart   # Challenge, UserChallengeProgress
│   │   ├── profile_models.dart     # UserProfile, Language
│   │   ├── reward_models.dart      # Reward, UserReward
│   │   └── social_models.dart      # Friend, LeaderboardEntry
│   │
│   ├── providers/ (State Management avec Provider)
│   │   ├── auth_provider.dart      # Login/Register/Logout
│   │   ├── profile_provider.dart   # UserProfile, avatar
│   │   ├── game_provider.dart      # Jeux, sessions
│   │   ├── challenge_provider.dart # Défis journaliers
│   │   ├── reward_provider.dart    # Badges, points
│   │   ├── social_provider.dart    # Amis, classement
│   │   └── theme_provider.dart     # Dark/Light mode
│   │
│   ├── services/
│   │   ├── api_service.dart        # HTTP client centralisé + intercepteurs
│   │   ├── auth_service.dart       # Logique auth (tokens, refresh)
│   │   ├── storage_service.dart    # SharedPreferences + Hive (cache)
│   │   ├── notification_service.dart # Push notifications (Firebase Cloud Messaging)
│   │   └── analytics_service.dart  # Tracking (Firebase Analytics)
│   │
│   ├── utils/
│   │   ├── constants.dart          # AppColors, AppStrings, endpoints
│   │   ├── formatters.dart         # Formatage dates, nombres, points
│   │   ├── validators.dart         # Email, password, username
│   │   └── extensions.dart         # Extensions utiles (String, DateTime)
│   │
│   ├── widgets/
│   │   ├── custom_button.dart      # ✅ Existant
│   │   ├── custom_textfield.dart   # ✅ Existant
│   │   ├── game_card.dart          # ✅ Existant
│   │   ├── progress_bar.dart       # Barre progression
│   │   ├── badge_widget.dart       # Affichage badges
│   │   ├── loading_indicator.dart  # Spinner customisé
│   │   ├── error_widget.dart       # Gestion erreurs UI
│   │   └── game_widgets/           # Widgets spécifiques jeux
│   │       ├── quiz_card.dart
│   │       ├── quiz_answer_button.dart
│   │       └── score_display.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart   # ✅ Existant (amélioré)
│   │   │   ├── register_screen.dart # ✅ Existant (amélioré)
│   │   │   ├── onboarding_screen.dart # Nouveau : tutoriel
│   │   │   ├── language_selection_screen.dart # Nouveau : choix langue
│   │   │   └── forgot_password_screen.dart # Nouveau
│   │   │
│   │   ├── home/
│   │   │   └── home_screen.dart    # ✅ Existant (améliorer)
│   │   │
│   │   ├── games/
│   │   │   ├── games_list_screen.dart     # Nouveau : liste jeux
│   │   │   ├── quiz_screen.dart          # Nouveau : jeu quiz
│   │   │   ├── memory_screen.dart        # Nouveau : jeu mémoire
│   │   │   ├── word_search_screen.dart   # Nouveau : recherche mots
│   │   │   ├── listening_screen.dart     # Nouveau : compréhension orale
│   │   │   └── game_result_screen.dart   # Nouveau : résultats
│   │   │
│   │   ├── challenges/
│   │   │   ├── challenges_screen.dart    # Nouveau : liste défis
│   │   │   ├── daily_challenge_screen.dart # Nouveau : défi du jour
│   │   │   └── challenge_result_screen.dart # Nouveau : résultat
│   │   │
│   │   ├── profile/
│   │   │   ├── profile_screen.dart       # Nouveau : profil utilisateur
│   │   │   ├── edit_profile_screen.dart  # Nouveau : édition
│   │   │   ├── statistics_screen.dart    # Nouveau : stats détaillées
│   │   │   └── settings_screen.dart      # Nouveau : paramètres
│   │   │
│   │   ├── social/
│   │   │   ├── leaderboard_screen.dart   # Nouveau : classement
│   │   │   ├── friends_screen.dart       # Nouveau : amis
│   │   │   └── share_screen.dart         # Nouveau : partage résultats
│   │   │
│   │   ├── rewards/
│   │   │   ├── rewards_screen.dart       # Nouveau : badges/récompenses
│   │   │   └── reward_detail_screen.dart # Nouveau : détail récompense
│   │   │
│   │   └── common/
│   │       ├── splash_screen.dart     # Nouveau : démarrage
│   │       └── error_screen.dart      # Nouveau : erreur globale
│   │
│   └── responsive/
│       ├── mobile_layout.dart      # Layout mobile
│       └── desktop_layout.dart     # Layout desktop
│
├── test/
│   ├── unit/
│   │   ├── providers/
│   │   ├── services/
│   │   └── utils/
│   └── widget/
│       └── screens/
│
├── pubspec.yaml                     # ✅ À mettre à jour avec deps
└── README.md
```

---

## Modèles de données (Flutter) {#modèles-flutter}

### 1. **game_models.dart** (À créer)

```dart
// Language model
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
      id: json['id'],
      name: json['name'],
      code: json['code'],
      flagIcon: json['flag_icon'],
    );
  }
}

// Game model
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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      gameType: json['game_type'],
      difficulty: json['difficulty'],
      language: Language.fromJson(json['language']),
      isExternal: json['is_external'],
      externalUrl: json['external_url'],
    );
  }
}

// Game Session - pour tracker progression utilisateur
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
      id: json['id'],
      userId: json['user'],
      gameId: json['game'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      score: json['score']?.toDouble(),
    );
  }
}

// Quiz Answer - pour quiz spécifiquement
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
}
```

### 2. **challenge_models.dart** (À créer)

```dart
class Challenge {
  final int id;
  final String title;
  final String description;
  final Language language;
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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      language: Language.fromJson(json['language']),
      pointsReward: json['points_reward'],
      isDaily: json['is_daily'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
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
      id: json['id'],
      userId: json['user'],
      challengeId: json['challenge'],
      isCompleted: json['is_completed'],
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
    );
  }
}
```

### 3. **profile_models.dart** (À créer)

```dart
class UserProfile {
  final int id;
  final User user;
  final List<Language> languagesLearning;
  final int currentStreak;
  final int totalPoints;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.user,
    required this.languagesLearning,
    required this.currentStreak,
    required this.totalPoints,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      user: User.fromJson(json['user']),
      languagesLearning: List<Language>.from(
        (json['languages_learning'] as List)
            .map((lang) => Language.fromJson(lang))
      ),
      currentStreak: json['current_streak'],
      totalPoints: json['total_points'],
      avatarUrl: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languages_learning_ids': languagesLearning.map((l) => l.id).toList(),
      'avatar': avatarUrl,
    };
  }
}
```

### 4. **reward_models.dart** (À créer)

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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      pointsRequired: json['points_required'],
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
      id: json['id'],
      userId: json['user'],
      rewardId: json['reward'],
      unlockedAt: DateTime.parse(json['unlocked_at']),
    );
  }
}
```

---

## Providers (State Management) {#providers}

### 1. **profile_provider.dart** (À créer)

```dart
import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService;
  
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider(this._apiService);

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMyProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await _apiService.getMyProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.updateProfile(profile);
      _userProfile = profile;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectLanguages(List<int> languageIds) async {
    try {
      await _apiService.updateLanguages(languageIds);
      await loadMyProfile();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  int get totalPoints => _userProfile?.totalPoints ?? 0;
  int get streak => _userProfile?.currentStreak ?? 0;
}
```

### 2. **game_provider.dart** (À créer)

```dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Game> _games = [];
  Game? _currentGame;
  GameSession? _currentSession;
  bool _isLoading = false;
  String? _errorMessage;

  GameProvider(this._apiService);

  List<Game> get games => _games;
  Game? get currentGame => _currentGame;
  bool get isLoading => _isLoading;

  Future<void> loadGames({
    int? difficulty,
    int? languageId,
    String? searchQuery,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _games = await _apiService.getGames(
        difficulty: difficulty,
        languageId: languageId,
        search: searchQuery,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startGame(Game game) async {
    _currentGame = game;
    try {
      _currentSession = await _apiService.startGameSession(game.id);
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> completeGame({required double score}) async {
    if (_currentSession == null) return;

    try {
      await _apiService.completeGameSession(_currentSession!.id, score);
      // Mettre à jour profil avec nouveaux points
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _currentGame = null;
      _currentSession = null;
      notifyListeners();
    }
  }
}
```

### 3. **challenge_provider.dart** (À créer)

```dart
import 'package:flutter/material.dart';
import '../models/challenge_models.dart';
import '../services/api_service.dart';

class ChallengeProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Challenge> _activeChallenges = [];
  Challenge? _dailyChallenge;
  bool _isLoading = false;

  ChallengeProvider(this._apiService);

  List<Challenge> get activeChallenges => _activeChallenges;
  Challenge? get dailyChallenge => _dailyChallenge;
  bool get isLoading => _isLoading;

  Future<void> loadActiveChallenges() async {
    _isLoading = true;
    notifyListeners();

    try {
      _activeChallenges = await _apiService.getActiveChallenges();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDailyChallenge() async {
    try {
      _dailyChallenge = await _apiService.getDailyChallenge();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> completeChallenge(int challengeId) async {
    try {
      await _apiService.completeChallenge(challengeId);
      await loadDailyChallenge();
    } catch (e) {
      // Handle error
    }
  }
}
```

### 4. **social_provider.dart** (À créer)

```dart
class LeaderboardEntry {
  final int rank;
  final String username;
  final int points;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.points,
    this.avatarUrl,
  });
}

class SocialProvider with ChangeNotifier {
  final ApiService _apiService;

  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;

  SocialProvider(this._apiService);

  List<LeaderboardEntry> get leaderboard => _leaderboard;

  Future<void> loadLeaderboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      final profiles = await _apiService.getLeaderboard();
      _leaderboard = profiles
          .asMap()
          .entries
          .map((e) => LeaderboardEntry(
            rank: e.key + 1,
            username: e.value.user.username,
            points: e.value.totalPoints,
            avatarUrl: e.value.avatarUrl,
          ))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## Services et API {#services-api}

### Mise à jour **api_service.dart**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/game_models.dart';
import '../models/challenge_models.dart';
import '../models/profile_models.dart';
import '../models/reward_models.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000/api";
  
  late http.Client _client;
  String? _token;

  ApiService({http.Client? client}) {
    _client = client ?? http.Client();
  }

  void setAuthToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Token $_token',
  };

  // ============ AUTH ============
  
  Future<User> register(RegisterRequest request) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: _headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception(json.decode(response.body)['detail'] ?? 'Registration failed');
    }
  }

  Future<User> login(LoginRequest request) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: _headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Login failed');
    }
  }

  // ============ PROFILES ============

  Future<UserProfile> getMyProfile() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/profiles/my_profile/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/profiles/my_profile/'),
      headers: _headers,
      body: json.encode(profile.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  Future<void> updateLanguages(List<int> languageIds) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/profiles/my_profile/'),
      headers: _headers,
      body: json.encode({
        'languages_learning_ids': languageIds,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update languages');
    }
  }

  Future<List<UserProfile>> getLeaderboard() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/profiles/leaderboard/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => UserProfile.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }

  // ============ GAMES ============

  Future<List<Game>> getGames({
    int? difficulty,
    int? languageId,
    String? search,
  }) async {
    final params = <String, String>{};
    if (difficulty != null) params['difficulty'] = difficulty.toString();
    if (languageId != null) params['language'] = languageId.toString();
    if (search != null) params['search'] = search;

    final uri = Uri.parse('$baseUrl/games/').replace(queryParameters: params);
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => Game.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load games');
    }
  }

  Future<GameSession> startGameSession(int gameId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/usergamesession/start/'),
      headers: _headers,
      body: json.encode({'game_id': gameId}),
    );

    if (response.statusCode == 201) {
      return GameSession.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to start game');
    }
  }

  Future<void> completeGameSession(int sessionId, double score) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/usergamesession/complete/$sessionId/'),
      headers: _headers,
      body: json.encode({'score': score}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete game');
    }
  }

  // ============ CHALLENGES ============

  Future<List<Challenge>> getActiveChallenges() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/challenges/active_challenges/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => Challenge.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load challenges');
    }
  }

  Future<Challenge> getDailyChallenge() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/daily-challenge/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Challenge.fromJson(json.decode(response.body)['challenge']);
    } else {
      throw Exception('Failed to load daily challenge');
    }
  }

  Future<void> completeChallenge(int challengeId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/challenges/$challengeId/complete_challenge/'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete challenge');
    }
  }

  // ============ REWARDS ============

  Future<List<Reward>> getAvailableRewards() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/rewards/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => Reward.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load rewards');
    }
  }

  Future<List<UserReward>> getUnlockedRewards() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/profiles/my_profile/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      // Parser rewards du profil
      return [];
    } else {
      throw Exception('Failed to load unlocked rewards');
    }
  }
}
```

---

## Écrans à développer {#écrans-à-développer}

### Priorité 1 : MVP (Semaines 1-2)

1. **OnboardingScreen** - Sélection langue
2. **GamesListScreen** - Liste des jeux disponibles
3. **QuizScreen** - Écran jeu Quiz
4. **ChallengesScreen** - Défis actifs
5. **ProfileScreen** - Profil utilisateur

### Priorité 2 : Jeux complémentaires (Semaine 3)

6. **MemoryScreen** - Jeu Memory
7. **WordSearchScreen** - Recherche mots
8. **ListeningScreen** - Compréhension orale

### Priorité 3 : Social (Semaine 4)

9. **LeaderboardScreen** - Classement
10. **FriendsScreen** - Amis
11. **ShareScreen** - Partage résultats

### Priorité 4 : Polish (Semaine 5)

12. **RewardsScreen** - Badges débloqués
13. **SettingsScreen** - Paramètres
14. **StatisticsScreen** - Stats détaillées

---

## Recommandations design (Figma) {#recommandations-design}

### Palette existante (validée)
- **Primaire** : #3A86FF (bleu confiance)
- **Secondaire** : #83C5BE (vert succès)
- **Accent** : #FF8C42 (orange énergie)
- **Fond** : #F8F9FA (blanc cassé)

### Screens Figma à créer

#### Mobile (Priorité)
```
1. Onboarding (3 écrans)
   - Splash screen
   - Language selection
   - Confirmation

2. Home Dashboard
   - Daily challenge (hero section)
   - Quick games grid
   - Progress bar
   - Streak counter

3. Game Screens
   - Quiz: Question + 4 réponses, timer
   - Memory: Grille 4x4, timer
   - Word Search: Grille mots
   - Result: Score, points earned, share button

4. Challenge Detail
   - Description
   - Progress
   - Reward badge
   - Submit button

5. Profile
   - Avatar + stats (points, streak)
   - Languages selected
   - Recent games
   - Settings link

6. Leaderboard
   - Top 10 users
   - Your rank
   - Points/streak columns

7. Rewards
   - Grid badges
   - Locked/Unlocked state
   - Progress to unlock
```

#### Desktop (Responsive)
```
Adapter les écrans mobile avec:
- Sidebar navigation (gauche)
- Main content (centre, max 1200px)
- Right panel (stats, leaderboard résumé)
```

### Composants réutilisables
```
- GameCard (existant)
- ProgressBar
- BadgeWidget
- ScoreDisplay
- LeaderboardRow
- ChallengeCard
- RewardBadge
```

### Animations proposées
- **Confetti** quand badge débloqué
- **Slide transition** entre écrans
- **Bounce** pour appui button
- **Pulse** pour daily challenge (reminder)
- **Fade** pour chargement

---

## Roadmap d'implémentation {#roadmap}

### **Phase 1 : Fondations (Semaines 1-2)**

#### Semaine 1
- [ ] Créer modèles Flutter (game, challenge, profile, reward)
- [ ] Implémenter ApiService complètement
- [ ] Créer ProfileProvider + ChallengeProvider
- [ ] Créer OnboardingScreen + LanguageSelectionScreen
- [ ] Tests unitaires ApiService

#### Semaine 2
- [ ] Créer GameProvider + GameListScreen
- [ ] Implémenter QuizScreen (écran jeu le plus simple)
- [ ] Créer ProfileScreen avec stats
- [ ] Intégrer daily challenge dans HomeScreen
- [ ] Ajouter error handling + loading states partout

### **Phase 2 : Jeux (Semaine 3)**

- [ ] MemoryScreen
- [ ] WordSearchScreen
- [ ] ListeningScreen (intégration audio)
- [ ] GameResultScreen réutilisable
- [ ] Ajouter animations confetti

### **Phase 3 : Social (Semaine 4)**

- [ ] SocialProvider
- [ ] LeaderboardScreen
- [ ] FriendsScreen + invite
- [ ] ShareScreen (partage résultats)
- [ ] Notifications push (Firebase)

### **Phase 4 : Optimisation (Semaine 5)**

- [ ] RewardsScreen
- [ ] SettingsScreen (langue UI, notifications)
- [ ] StatisticsScreen détaillé
- [ ] Responsive design desktop
- [ ] Cache local (Hive)
- [ ] Offline mode basique

### **Phase 5 : Deploy + Tests (Semaine 6)**

- [ ] Couverture tests >80%
- [ ] Performance optimization
- [ ] App store & Play store submission
- [ ] Beta testing

---

## Dépendances pubspec.yaml (À ajouter)

```yaml
dependencies:
  # State Management
  provider: ^6.1.1

  # Networking & Storage
  http: ^1.1.0
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Security
  flutter_secure_storage: ^9.0.0

  # UI/UX
  google_fonts: ^6.1.0
  intl: ^0.19.0  # Internationalization
  lottie: ^2.6.0  # Animations
  confetti: ^0.7.0  # Confetti effect

  # Navigation
  go_router: ^14.0.0

  # Firebase
  firebase_core: ^25.0.0
  firebase_messaging: ^14.7.0
  firebase_analytics: ^11.0.0

  # Misc
  uuid: ^4.0.0
  timeago: ^3.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

---

## Points clés d'amélioration immédiats

1. ✅ **Linter/Analyse** : DONE (flutter analyze clean)
2. **Authentification réelle** : Connecter ApiService à backend (endpoint /auth/login/, /auth/register/)
3. **Token persistence** : Sauvegarder token dans flutter_secure_storage après login
4. **Navigation robuste** : Utiliser GoRouter au lieu de pushNamed
5. **Responsive** : Ajouter MediaQuery breakpoints pour desktop
6. **Internationalization** : Intégrer intl + app_*.arb files
7. **Error handling** : SnackBar/Dialog pour chaque erreur API
8. **Loading states** : Ajouter shimmer/skeleton pour chaque écran
9. **Offline support** : Cache Hive + sync quand online
10. **Analytics** : Firebase Analytics pour tracker engagement

---

## Conclusion

LinguaPlay dispose d'une **base solide** (backend API complète, auth basique, design system) mais nécessite un **développement frontend important** pour align au cahier des charges.

**Priorité immédiate** : Phases 1-2 (4 semaines) pour avoir un MVP jouable avec 3 types de jeux, défis journaliers et profil.

**Ressources recommandées** :
- 1 Flutter dev senior (lead architecture)
- 1 Flutter dev junior (widgets + screens)
- 1 QA/tester
- Figma designer pour mockups high-fidelity

**Budget estimé** : €40-60K pour MVP, €80-120K pour full product

---

**Prochaines étapes** :
1. Valider architecture avec équipe
2. Créer Figma wireframes haute fidélité
3. Commencer Phase 1 implémentation
4. Setup CI/CD (GitHub Actions)
5. Tests avec utilisateurs réels (Testflight/Play Store beta)

