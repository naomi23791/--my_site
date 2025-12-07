import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../models/challenge_model.dart';
import '../models/profile_model.dart';
import '../models/reward_model.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000/api";
  
  String? _token;
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  // Obtenir les headers avec token si disponible
  Map<String, String> get headers {
    final h = _defaultHeaders.map((k, v) => MapEntry(k, v));
    if (_token != null) {
      h['Authorization'] = 'Token $_token';
    }
    return h;
  }

  // Définir le token
  void setAuthToken(String token) {
    _token = token;
  }

  // Effacer le token
  void clearAuthToken() {
    _token = null;
  }

  // ============= AUTH ENDPOINTS =============

  // Inscription
  Future<User> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: _defaultHeaders,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final user = User.fromJson(data['user']);
      final token = data['token'] as String;
      setAuthToken(token);
      return user.copyWith(token: token);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // Connexion
  Future<User> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: _defaultHeaders,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final user = User.fromJson(data['user']);
      final token = data['token'] as String;
      setAuthToken(token);
      return user.copyWith(token: token);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Profil utilisateur
  Future<User> getProfile() async {
    if (_token == null) {
      throw Exception('No authentication token set');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 401) {
      clearAuthToken();
      throw Exception('Unauthorized: Token invalid');
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  // ============= GAMES ENDPOINTS =============

  // Obtenir toutes les langues
  Future<List<Language>> getLanguages() async {
  final response = await http.get(
    Uri.parse('$baseUrl/languages/'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => Language.fromJson(json as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Failed to load languages: ${response.statusCode} - ${response.body}');
  }
}

  // Obtenir les jeux d'une langue
  Future<List<Game>> getGamesByLanguage(int languageId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/?language=$languageId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> games = data['results'] ?? data;
      return games.map((json) => Game.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load games: ${response.body}');
    }
  }

  // Obtenir les détails d'un jeu
  Future<Game> getGameDetail(int gameId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/$gameId/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Game.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load game: ${response.body}');
    }
  }

  // Obtenir les questions d'un jeu (prototype)
  Future<List<QuizQuestion>> getGameQuestions(int gameId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/$gameId/questions/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => QuizQuestion.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load game questions: ${response.body}');
    }
  }

  // Démarrer une session de jeu
  Future<GameSession> startGameSession(int gameId) async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/usergamesession/start/'),
      headers: headers,
      body: json.encode({
        'game_id': gameId,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return GameSession.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to start game session: ${response.body}');
    }
  }

  // Compléter une session de jeu
  Future<GameSession> completeGameSession(int sessionId, int score) async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await http.patch(
      Uri.parse('$baseUrl/usergamesession/complete/$sessionId/'),
      headers: headers,
      body: json.encode({
        'score': score,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return GameSession.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to complete game session: ${response.body}');
    }
  }

  // ============= CHALLENGES ENDPOINTS =============

  // Obtenir les défis actifs
  Future<List<Challenge>> getActiveChallenges(int languageId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/challenges/challenges/?status=active&language_id=$languageId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> challenges = data['results'] ?? data;
      return challenges.map((json) => Challenge.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load challenges: ${response.body}');
    }
  }

  // Obtenir le défi du jour
  Future<Challenge> getDailyChallenge() async {
    final response = await http.get(
      Uri.parse('$baseUrl/challenges/daily-challenge/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Challenge.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load daily challenge: ${response.body}');
    }
  }

  // Démarrer un défi
  Future<UserChallengeProgress> startChallenge(int challengeId) async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/challenges/user-challenge-progress/'),
      headers: headers,
      body: json.encode({
        'challenge_id': challengeId,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return UserChallengeProgress.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to start challenge: ${response.body}');
    }
  }

  // Compléter un défi
  Future<UserChallengeProgress> completeChallenge(int progressId, int score) async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await http.patch(
      Uri.parse('$baseUrl/challenges/user-challenge-progress/$progressId/'),
      headers: headers,
      body: json.encode({
        'current_score': score,
        'status': 'completed',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserChallengeProgress.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to complete challenge: ${response.body}');
    }
  }

  // ============= PROFILE ENDPOINTS =============

  // Obtenir le profil utilisateur
  Future<UserProfile> getUserProfile() async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/profiles/user-profiles/me/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load user profile: ${response.body}');
    }
  }

  // Mettre à jour le profil utilisateur
  Future<UserProfile> updateUserProfile({
    String? username,
    String? bio,
    List<int>? selectedLanguages,
  }) async {
    if (_token == null) throw Exception('Not authenticated');

    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (bio != null) body['bio'] = bio;
    if (selectedLanguages != null) body['selected_languages'] = selectedLanguages;

    final response = await http.patch(
      Uri.parse('$baseUrl/profiles/user-profiles/me/'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update user profile: ${response.body}');
    }
  }

  // ============= REWARDS ENDPOINTS =============

  // Obtenir tous les badges/récompenses
  Future<List<Reward>> getRewards() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rewards/rewards/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> rewards = data['results'] ?? data;
      return rewards.map((json) => Reward.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load rewards: ${response.body}');
    }
  }

  // Obtenir les récompenses gagnées par l'utilisateur
  Future<List<UserReward>> getUserRewards() async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/rewards/user-rewards/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> userRewards = data['results'] ?? data;
      return userRewards.map((json) => UserReward.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load user rewards: ${response.body}');
    }
  }

  // ============= UTILITY METHODS =============

  // Fonction helper pour les requêtes GET avec gestion d'erreurs
  Future<T> get<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch $endpoint: ${response.body}');
    }
  }
}