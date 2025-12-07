import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService;

  bool _isLoading = false;
  UserProfile? _userProfile;
  String? _error;

  ProfileProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Getters
  bool get isLoading => _isLoading;
  UserProfile? get userProfile => _userProfile;
  String? get error => _error;

  // Charger le profil de l'utilisateur
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProfile = await _apiService.getUserProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le profil
  Future<void> updateProfile({
    String? username,
    String? bio,
    List<int>? selectedLanguages,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProfile = await _apiService.updateUserProfile(
        username: username,
        bio: bio,
        selectedLanguages: selectedLanguages,
      );
      _userProfile = updatedProfile;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter une langue à la sélection
  Future<void> addLanguage(int languageId) async {
    if (_userProfile == null) return;
    
    final updatedLanguages = [..._userProfile!.selectedLanguages];
    if (!updatedLanguages.contains(languageId)) {
      updatedLanguages.add(languageId);
    }

    await updateProfile(selectedLanguages: updatedLanguages);
  }

  // Supprimer une langue de la sélection
  Future<void> removeLanguage(int languageId) async {
    if (_userProfile == null) return;
    
    final updatedLanguages = [..._userProfile!.selectedLanguages];
    updatedLanguages.remove(languageId);

    await updateProfile(selectedLanguages: updatedLanguages);
  }

  // Réinitialiser
  void reset() {
    _userProfile = null;
    _error = null;
    notifyListeners();
  }
}
