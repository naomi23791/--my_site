import 'package:flutter/material.dart';
import '../models/challenge_model.dart';
import '../services/api_service.dart';

class ChallengeProvider with ChangeNotifier {
  final ApiService _apiService;

  bool _isLoading = false;
  List<Challenge> _activeChallenges = [];
  Challenge? _dailyChallenge;
  final List<UserChallengeProgress> _userProgress = [];
  String? _error;
  int? _selectedLanguageId;

  ChallengeProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Getters
  bool get isLoading => _isLoading;
  List<Challenge> get activeChallenges => _activeChallenges;
  Challenge? get dailyChallenge => _dailyChallenge;
  List<UserChallengeProgress> get userProgress => _userProgress;
  String? get error => _error;
  int? get selectedLanguageId => _selectedLanguageId;

  // Charger les défis actifs
  Future<void> loadActiveChallenges(int languageId) async {
    _isLoading = true;
    _error = null;
    _selectedLanguageId = languageId;
    notifyListeners();

    try {
      _activeChallenges = await _apiService.getActiveChallenges(languageId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger le défi du jour
  Future<void> loadDailyChallenge() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dailyChallenge = await _apiService.getDailyChallenge();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Démarrer un défi
  Future<UserChallengeProgress> startChallenge(int challengeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final progress = await _apiService.startChallenge(challengeId);
      _userProgress.add(progress);
      return progress;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Compléter un défi
  Future<UserChallengeProgress> completeChallenge(int progressId, int score) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final progress = await _apiService.completeChallenge(progressId, score);
      
      // Mettre à jour le progrès dans la liste
      final index = _userProgress.indexWhere((p) => p.id == progressId);
      if (index != -1) {
        _userProgress[index] = progress;
      }
      
      return progress;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtenir le progrès d'un défi spécifique
  UserChallengeProgress? getChallengeProgress(int challengeId) {
    try {
      return _userProgress.firstWhere(
        (p) => p.challengeId == challengeId,
      );
    } catch (e) {
      return null;
    }
  }

  // Réinitialiser
  void reset() {
    _error = null;
    notifyListeners();
  }
}
