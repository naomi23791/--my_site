// Challenge model
class Challenge {
  final int id;
  final int languageId;
  final String title;
  final String description;
  final String? reward;
  final int difficulty; // 1-5
  final String status; // 'active', 'completed', 'expired'
  final DateTime startDate;
  final DateTime endDate;
  final int? targetScore;
  final String? instructions;

  Challenge({
    required this.id,
    required this.languageId,
    required this.title,
    required this.description,
    this.reward,
    required this.difficulty,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.targetScore,
    this.instructions,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as int,
      languageId: json['language_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      reward: json['reward'] as String?,
      difficulty: json['difficulty'] as int? ?? 1,
      status: json['status'] as String? ?? 'active',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      targetScore: json['target_score'] as int?,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'language_id': languageId,
    'title': title,
    'description': description,
    'reward': reward,
    'difficulty': difficulty,
    'status': status,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'target_score': targetScore,
    'instructions': instructions,
  };

  Challenge copyWith({
    int? id,
    int? languageId,
    String? title,
    String? description,
    String? reward,
    int? difficulty,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? targetScore,
    String? instructions,
  }) {
    return Challenge(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetScore: targetScore ?? this.targetScore,
      instructions: instructions ?? this.instructions,
    );
  }

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isExpired => status == 'expired';
  bool get isOngoing => DateTime.now().isBefore(endDate);
}

// User Challenge Progress model
class UserChallengeProgress {
  final int id;
  final int userId;
  final int challengeId;
  final int currentScore;
  final String status; // 'active', 'completed', 'failed'
  final DateTime startedAt;
  final DateTime? completedAt;
  final int attemptsCount;
  final Map<String, dynamic>? progressData;

  UserChallengeProgress({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.currentScore,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.attemptsCount,
    this.progressData,
  });

  factory UserChallengeProgress.fromJson(Map<String, dynamic> json) {
    return UserChallengeProgress(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      challengeId: json['challenge_id'] as int,
      currentScore: json['current_score'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
        ? DateTime.parse(json['completed_at'] as String)
        : null,
      attemptsCount: json['attempts_count'] as int? ?? 1,
      progressData: json['progress_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'challenge_id': challengeId,
    'current_score': currentScore,
    'status': status,
    'started_at': startedAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'attempts_count': attemptsCount,
    'progress_data': progressData,
  };

  UserChallengeProgress copyWith({
    int? id,
    int? userId,
    int? challengeId,
    int? currentScore,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? attemptsCount,
    Map<String, dynamic>? progressData,
  }) {
    return UserChallengeProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      currentScore: currentScore ?? this.currentScore,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      progressData: progressData ?? this.progressData,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isActive => status == 'active';
  bool get isFailed => status == 'failed';
}
