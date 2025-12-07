import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  final ApiService _apiService;

  bool _isLoading = false;
  List<Language> _languages = [];
  List<Game> _games = [];
  Game? _selectedGame;
  final List<GameSession> _userSessions = [];
  String? _error;
  int? _selectedLanguageId;

  GameProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Quiz state
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _currentScore = 0;
  int? _currentSessionId;
  bool _answered = false;
  bool? _lastAnswerCorrect;
  String? _lastSelectedOption;

  List<QuizQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get currentScore => _currentScore;
  QuizQuestion? get currentQuestion => _questions.isNotEmpty && _currentQuestionIndex < _questions.length ? _questions[_currentQuestionIndex] : null;
  bool get answered => _answered;
  bool? get lastAnswerCorrect => _lastAnswerCorrect;
  String? get lastSelectedOption => _lastSelectedOption;

  // Getters
  bool get isLoading => _isLoading;
  List<Language> get languages => _languages;
  List<Game> get games => _games;
  Game? get selectedGame => _selectedGame;
  List<GameSession> get userSessions => _userSessions;
  String? get error => _error;
  int? get selectedLanguageId => _selectedLanguageId;

  // Charger les langues
  Future<void> loadLanguages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _languages = await _apiService.getLanguages();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Persist selected languages locally (for non-auth users)
  Future<void> persistSelectedLanguages(List<int> languageIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = languageIds.map((e) => e.toString()).toList();
      await prefs.setStringList('selected_languages', stringList);
    } catch (_) {}
  }

  // Load persisted selected languages (returns list of ids)
  Future<List<int>> loadPersistedSelectedLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('selected_languages') ?? [];
      return list.map((s) => int.tryParse(s)).whereType<int>().toList();
    } catch (_) {
      return [];
    }
  }

  // Charger les jeux d'une langue
  Future<void> loadGamesByLanguage(int languageId) async {
    _isLoading = true;
    _error = null;
    _selectedLanguageId = languageId;
    notifyListeners();

    try {
      _games = await _apiService.getGamesByLanguage(languageId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sélectionner un jeu
  Future<void> selectGame(int gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedGame = await _apiService.getGameDetail(gameId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Démarrer une partie
  Future<GameSession> startGame(int gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final session = await _apiService.startGameSession(gameId);
      _userSessions.add(session);
      _currentSessionId = session.id;
      return session;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les questions pour le jeu sélectionné
  Future<void> loadQuestions(int gameId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _apiService.getGameQuestions(gameId);
      _currentQuestionIndex = 0;
      _currentScore = 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Soumettre une réponse pour la question courante (ne passe pas automatiquement à la suivante)
  Future<void> submitAnswer(String selectedOption) async {
    if (currentQuestion == null) return;
    final correct = selectedOption == currentQuestion!.correctAnswer;
    _lastSelectedOption = selectedOption;
    _lastAnswerCorrect = correct;
    if (correct) {
      _currentScore += 1;
    }
    _answered = true;
    notifyListeners();
  }

  // Passer à la question suivante
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length) {
      _currentQuestionIndex += 1;
    }
    _answered = false;
    _lastAnswerCorrect = null;
    _lastSelectedOption = null;
    notifyListeners();
  }

  // Terminer la partie et envoyer le score
  Future<GameSession?> finishCurrentGame() async {
    if (_currentSessionId == null) return null;
    try {
      final session = await completeGame(_currentSessionId!, _currentScore);
      return session;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Terminer une partie
  Future<GameSession> completeGame(int sessionId, int score) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final session = await _apiService.completeGameSession(sessionId, score);
      
      // Mettre à jour la session dans la liste
      final index = _userSessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _userSessions[index] = session;
      }
      
      return session;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Réinitialiser
  void reset() {
    _selectedGame = null;
    _error = null;
    notifyListeners();
  }

  // Set selected game directly (useful for tests / injection)
  void setSelectedGame(Game game) {
    _selectedGame = game;
    notifyListeners();
  }
}
