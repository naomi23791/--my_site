// User Profile model
class UserProfile {
  final int id;
  final int userId;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int totalXP;
  final int level;
  final List<int> selectedLanguages; // Language IDs
  final Map<String, int> gameStats; // game_type -> score
  final DateTime createdAt;
  final DateTime lastActiveAt;

  UserProfile({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.totalXP,
    required this.level,
    required this.selectedLanguages,
    required this.gameStats,
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      totalXP: json['total_xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      selectedLanguages: List<int>.from((json['selected_languages'] ?? []) as List),
      gameStats: Map<String, int>.from((json['game_stats'] ?? {}) as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'username': username,
    'avatar_url': avatarUrl,
    'bio': bio,
    'total_xp': totalXP,
    'level': level,
    'selected_languages': selectedLanguages,
    'game_stats': gameStats,
    'created_at': createdAt.toIso8601String(),
    'last_active_at': lastActiveAt.toIso8601String(),
  };

  UserProfile copyWith({
    int? id,
    int? userId,
    String? username,
    String? avatarUrl,
    String? bio,
    int? totalXP,
    int? level,
    List<int>? selectedLanguages,
    Map<String, int>? gameStats,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      gameStats: gameStats ?? this.gameStats,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  // Helper methods
  int getGameScore(String gameType) => gameStats[gameType] ?? 0;
  
  void updateGameScore(String gameType, int score) {
    gameStats[gameType] = score;
  }

  bool hasLanguageSelected(int languageId) => selectedLanguages.contains(languageId);
}
