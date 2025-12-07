import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _token;
  User? _user;
  String? _error;

  AuthProvider({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get user => _user;
  String? get error => _error;

  // Vérifier si l'utilisateur est déjà connecté (au démarrage de l'app)
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      
      if (savedToken != null) {
        _token = savedToken;
        _apiService.setAuthToken(savedToken);
        
        // Valider le token en chargeant le profil
        _user = await _apiService.getProfile();
        _isAuthenticated = true;
      }
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
      _user = null;
    }
    notifyListeners();
  }

  // Connexion
  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest(username: username, password: password);
      final user = await _apiService.login(request);
      
      _user = user;
      _token = user.token;
      _isAuthenticated = true;

      // Sauvegarder le token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Inscription
  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
      );
      final user = await _apiService.register(request);
      
      _user = user;
      _token = user.token;
      _isAuthenticated = true;

      // Sauvegarder le token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Effacer le token du service API
      _apiService.clearAuthToken();
      
      // Effacer le token stocké
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      _isAuthenticated = false;
      _token = null;
      _user = null;
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}