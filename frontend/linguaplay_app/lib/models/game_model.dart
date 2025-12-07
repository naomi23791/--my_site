// Language model
class Language {
  final int id;
  final String code;
  final String name;
  final String? flag;
  final bool isActive;

  Language({
    required this.id,
    required this.code,
    required this.name,
    this.flag,
    required this.isActive,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      flag: json['flag'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'flag': flag,
    'is_active': isActive,
  };

  Language copyWith({
    int? id,
    String? code,
    String? name,
    String? flag,
    bool? isActive,
  }) {
    return Language(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      flag: flag ?? this.flag,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Game model
class Game {
  final int id;
  final String title;
  final String description;
  final String gameType; // 'quiz', 'memory', 'wordsearch'
  final int languageId;
  final int difficulty; // 1-5
  final int maxScore;
  final String? thumbnailUrl;
  final bool isActive;
  final DateTime createdAt;

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.gameType,
    required this.languageId,
    required this.difficulty,
    required this.maxScore,
    this.thumbnailUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      gameType: json['game_type'] as String,
      languageId: json['language_id'] as int,
      difficulty: json['difficulty'] as int? ?? 1,
      maxScore: json['max_score'] as int? ?? 100,
      thumbnailUrl: json['thumbnail'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'game_type': gameType,
    'language_id': languageId,
    'difficulty': difficulty,
    'max_score': maxScore,
    'thumbnail': thumbnailUrl,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };

  Game copyWith({
    int? id,
    String? title,
    String? description,
    String? gameType,
    int? languageId,
    int? difficulty,
    int? maxScore,
    String? thumbnailUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      gameType: gameType ?? this.gameType,
      languageId: languageId ?? this.languageId,
      difficulty: difficulty ?? this.difficulty,
      maxScore: maxScore ?? this.maxScore,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

}

// Quiz Question model
class QuizQuestion {
  final int id;
  final int gameId;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final int order;

  QuizQuestion({
    required this.id,
    required this.gameId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.order,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int,
      gameId: json['game_id'] as int,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correct_answer'] as String,
      explanation: json['explanation'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'game_id': gameId,
    'question': question,
    'options': options,
    'correct_answer': correctAnswer,
    'explanation': explanation,
    'order': order,
  };
}

// Game Session model
class GameSession {
  final int id;
  final int userId;
  final int gameId;
  final int score;
  final int? maxScore;
  final String status; // 'in_progress', 'completed', 'abandoned'
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? sessionData; // For storing game-specific data

  GameSession({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.score,
    this.maxScore,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.sessionData,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      gameId: json['game_id'] as int,
      score: json['score'] as int? ?? 0,
      maxScore: json['max_score'] as int?,
      status: json['status'] as String? ?? 'in_progress',
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null 
        ? DateTime.parse(json['completed_at'] as String)
        : null,
      sessionData: json['session_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'game_id': gameId,
    'score': score,
    'max_score': maxScore,
    'status': status,
    'started_at': startedAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'session_data': sessionData,
  };

  GameSession copyWith({
    int? id,
    int? userId,
    int? gameId,
    int? score,
    int? maxScore,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? sessionData,
  }) {
    return GameSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameId: gameId ?? this.gameId,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      sessionData: sessionData ?? this.sessionData,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isAbandoned => status == 'abandoned';
}
