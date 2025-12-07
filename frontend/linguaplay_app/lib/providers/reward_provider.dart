import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../services/api_service.dart';

class RewardProvider with ChangeNotifier {
  final ApiService _apiService;

  bool _isLoading = false;
  List<Reward> _allRewards = [];
  List<UserReward> _userRewards = [];
  String? _error;

  RewardProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Getters
  bool get isLoading => _isLoading;
  List<Reward> get allRewards => _allRewards;
  List<UserReward> get userRewards => _userRewards;
  String? get error => _error;

  // Charger tous les badges/récompenses disponibles
  Future<void> loadAllRewards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allRewards = await _apiService.getRewards();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les récompenses gagnées par l'utilisateur
  Future<void> loadUserRewards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userRewards = await _apiService.getUserRewards();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtenir les détails d'une récompense gagnée
  Reward? getRewardDetails(int rewardId) {
    try {
      return _allRewards.firstWhere((r) => r.id == rewardId);
    } catch (e) {
      return null;
    }
  }

  // Vérifier si l'utilisateur a gagné une récompense
  bool hasReward(int rewardId) {
    return _userRewards.any((ur) => ur.rewardId == rewardId);
  }

  // Obtenir les récompenses non vues
  List<UserReward> getUnviewedRewards() {
    return _userRewards.where((ur) => !ur.isViewed).toList();
  }

  // Réinitialiser
  void reset() {
    _allRewards = [];
    _userRewards = [];
    _error = null;
    notifyListeners();
  }
}
