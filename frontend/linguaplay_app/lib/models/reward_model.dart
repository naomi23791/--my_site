// Reward model
class Reward {
  final int id;
  final String title;
  final String description;
  final String? badgeUrl;
  final int requiredXP;
  final String rewardType; // 'badge', 'title', 'avatar'
  final String? rewardValue;
  final bool isActive;
  final DateTime createdAt;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    this.badgeUrl,
    required this.requiredXP,
    required this.rewardType,
    this.rewardValue,
    required this.isActive,
    required this.createdAt,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      badgeUrl: json['badge_url'] as String?,
      requiredXP: json['required_xp'] as int,
      rewardType: json['reward_type'] as String,
      rewardValue: json['reward_value'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'badge_url': badgeUrl,
    'required_xp': requiredXP,
    'reward_type': rewardType,
    'reward_value': rewardValue,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };

  Reward copyWith({
    int? id,
    String? title,
    String? description,
    String? badgeUrl,
    int? requiredXP,
    String? rewardType,
    String? rewardValue,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      badgeUrl: badgeUrl ?? this.badgeUrl,
      requiredXP: requiredXP ?? this.requiredXP,
      rewardType: rewardType ?? this.rewardType,
      rewardValue: rewardValue ?? this.rewardValue,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// User Reward model (represents a reward earned by a user)
class UserReward {
  final int id;
  final int userId;
  final int rewardId;
  final DateTime earnedAt;
  final bool isViewed;

  UserReward({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.earnedAt,
    required this.isViewed,
  });

  factory UserReward.fromJson(Map<String, dynamic> json) {
    return UserReward(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      rewardId: json['reward_id'] as int,
      earnedAt: DateTime.parse(json['earned_at'] as String),
      isViewed: json['is_viewed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'reward_id': rewardId,
    'earned_at': earnedAt.toIso8601String(),
    'is_viewed': isViewed,
  };

  UserReward copyWith({
    int? id,
    int? userId,
    int? rewardId,
    DateTime? earnedAt,
    bool? isViewed,
  }) {
    return UserReward(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rewardId: rewardId ?? this.rewardId,
      earnedAt: earnedAt ?? this.earnedAt,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}
