import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionHistoryEntry {
  final DateTime date;
  final String activity;
  final int xp;

  SessionHistoryEntry({
    required this.date,
    required this.activity,
    required this.xp,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'activity': activity,
        'xp': xp,
      };

  factory SessionHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SessionHistoryEntry(
      date: DateTime.parse(json['date'] as String),
      activity: json['activity'] as String,
      xp: json['xp'] as int,
    );
  }
}

class BadgeProgress {
  final String id;
  final String title;
  final String description;
  final int threshold;
  DateTime? unlockedAt;

  BadgeProgress({
    required this.id,
    required this.title,
    required this.description,
    required this.threshold,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'threshold': threshold,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory BadgeProgress.fromJson(Map<String, dynamic> json) {
    return BadgeProgress(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      threshold: json['threshold'] as int,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt'] as String) : null,
    );
  }
}

class XPProvider with ChangeNotifier {
  int _dailyXP = 0;
  int _totalXP = 0;
  int _streak = 0;
  DateTime? _lastActivityDate;
  int _dailyGoal = 50; // 50 XP par jour
  final List<SessionHistoryEntry> _history = [];
  final List<BadgeProgress> _badges = [
    BadgeProgress(
      id: 'streak_3',
      title: 'Démarrage en trombe',
      description: '3 jours consécutifs',
      threshold: 3,
    ),
    BadgeProgress(
      id: 'streak_7',
      title: 'Routine en place',
      description: '7 jours consécutifs',
      threshold: 7,
    ),
    BadgeProgress(
      id: 'streak_30',
      title: 'Champion',
      description: '30 jours consécutifs',
      threshold: 30,
    ),
  ];

  // Getters
  int get dailyXP => _dailyXP;
  int get totalXP => _totalXP;
  int get streak => _streak;
  int get dailyGoal => _dailyGoal;
  double get dailyProgress => _dailyXP / _dailyGoal;
  bool get isDailyGoalReached => _dailyXP >= _dailyGoal;
  List<SessionHistoryEntry> get history => List.unmodifiable(_history);
  List<BadgeProgress> get badges => List.unmodifiable(_badges);

  XPProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dailyXP = prefs.getInt('daily_xp') ?? 0;
      _totalXP = prefs.getInt('total_xp') ?? 0;
      _streak = prefs.getInt('streak') ?? 0;
      final lastDateStr = prefs.getString('last_activity_date');
      _lastActivityDate = lastDateStr != null ? DateTime.parse(lastDateStr) : null;
      _dailyGoal = prefs.getInt('daily_goal') ?? 50;
      final historyJson = prefs.getStringList('xp_history') ?? [];
      _history
        ..clear()
        ..addAll(historyJson.map((item) => SessionHistoryEntry.fromJson(
              Map<String, dynamic>.from(
                jsonDecode(item) as Map<String, dynamic>,
              ),
            )));
      final badgesJson = prefs.getStringList('xp_badges');
      if (badgesJson != null && badgesJson.length == _badges.length) {
        for (var i = 0; i < _badges.length; i++) {
          final data = Map<String, dynamic>.from(jsonDecode(badgesJson[i]) as Map<String, dynamic>);
          _badges[i].unlockedAt = data['unlockedAt'] != null ? DateTime.parse(data['unlockedAt'] as String) : null;
        }
      }

      // Check if we need to reset daily XP (new day)
      _checkDailyReset();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading XP data: $e');
    }
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    if (_lastActivityDate == null) {
      return;
    }

    final daysDifference = now.difference(_lastActivityDate!).inDays;
    
    if (daysDifference == 0) {
      // Same day, keep streak
      return;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      _streak++;
    } else {
      // Streak broken
      _streak = 1;
    }

    // Reset daily XP if new day
    if (daysDifference > 0) {
      _dailyXP = 0;
    }
  }

  Future<void> addXP(int amount, {String activity = 'Session'}) async {
    _dailyXP += amount;
    _totalXP += amount;
    _lastActivityDate = DateTime.now();
    _history.insert(0, SessionHistoryEntry(date: _lastActivityDate!, activity: activity, xp: amount));
    if (_history.length > 20) {
      _history.removeLast();
    }

    // Check if streak should increment
    _checkDailyReset();
    _evaluateBadges();

    await _saveData();
    notifyListeners();
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('daily_xp', _dailyXP);
      await prefs.setInt('total_xp', _totalXP);
      await prefs.setInt('streak', _streak);
      if (_lastActivityDate != null) {
        await prefs.setString('last_activity_date', _lastActivityDate!.toIso8601String());
      }
      await prefs.setInt('daily_goal', _dailyGoal);
      await prefs.setStringList(
        'xp_history',
        _history.map((entry) => jsonEncode(entry.toJson())).toList(),
      );
      await prefs.setStringList(
        'xp_badges',
        _badges.map((badge) => jsonEncode(badge.toJson())).toList(),
      );
    } catch (e) {
      debugPrint('Error saving XP data: $e');
    }
  }

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    await _saveData();
    notifyListeners();
  }

  void resetDailyXP() {
    _dailyXP = 0;
    _saveData();
    notifyListeners();
  }

  void _evaluateBadges() {
    for (final badge in _badges) {
      if (!badge.isUnlocked && _streak >= badge.threshold) {
        badge.unlockedAt = DateTime.now();
      }
    }
  }
}

