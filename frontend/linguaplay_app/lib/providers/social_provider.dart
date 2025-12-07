import 'package:flutter/material.dart';

// Modèle simple pour les utilisateurs dans le classement
class LeaderboardUser {
  final int userId;
  final String username;
  final String? avatarUrl;
  final int xpPoints;
  final int level;
  final int rank;

  LeaderboardUser({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.xpPoints,
    required this.level,
    required this.rank,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      xpPoints: json['xp_points'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      rank: json['rank'] as int? ?? 0,
    );
  }
}

class SocialProvider with ChangeNotifier {
  bool _isLoading = false;
  List<LeaderboardUser> _globalLeaderboard = [];
  List<LeaderboardUser> _languageLeaderboard = [];
  String? _error;
  int? _userRank;

  // Getters
  bool get isLoading => _isLoading;
  List<LeaderboardUser> get globalLeaderboard => _globalLeaderboard;
  List<LeaderboardUser> get languageLeaderboard => _languageLeaderboard;
  String? get error => _error;
  int? get userRank => _userRank;

  // Charger le classement global (simulé pour le moment)
  Future<void> loadGlobalLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Pour le moment, ce sont des données simulées
      // En production, ce serait un appel API
      _globalLeaderboard = [
        LeaderboardUser(
          userId: 1,
          username: 'TopPlayer',
          xpPoints: 5000,
          level: 25,
          rank: 1,
        ),
        LeaderboardUser(
          userId: 2,
          username: 'LanguageMaster',
          xpPoints: 4800,
          level: 24,
          rank: 2,
        ),
        LeaderboardUser(
          userId: 3,
          username: 'GameGuru',
          xpPoints: 4500,
          level: 23,
          rank: 3,
        ),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger le classement par langue (simulé pour le moment)
  Future<void> loadLanguageLeaderboard(int languageId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Données simulées
      _languageLeaderboard = [
        LeaderboardUser(
          userId: 1,
          username: 'FrenchPro',
          xpPoints: 3000,
          level: 18,
          rank: 1,
        ),
        LeaderboardUser(
          userId: 2,
          username: 'FrenchLearner',
          xpPoints: 2500,
          level: 15,
          rank: 2,
        ),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtenir le rang de l'utilisateur
  void setUserRank(int rank) {
    _userRank = rank;
    notifyListeners();
  }

  // Réinitialiser
  void reset() {
    _globalLeaderboard = [];
    _languageLeaderboard = [];
    _userRank = null;
    _error = null;
    notifyListeners();
  }
}
