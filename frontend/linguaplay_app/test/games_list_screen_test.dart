import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:linguaplay_app/screens/games/games_list_screen.dart';
import 'package:linguaplay_app/providers/game_provider.dart';
import 'package:linguaplay_app/models/game_model.dart';

// Test subclass that overrides network methods of the real GameProvider
class TestGameProvider extends GameProvider {
  TestGameProvider(): super(apiService: null);

  bool _isLoading = false;
  List<Language> _languages = [];
  List<Game> _games = [];
  int? _selectedLanguageId;

  @override
  bool get isLoading => _isLoading;

  @override
  List<Language> get languages => _languages;

  @override
  List<Game> get games => _games;

  @override
  int? get selectedLanguageId => _selectedLanguageId;

  @override
  Future<void> loadLanguages() async {
    _isLoading = true;
    notifyListeners();
    _languages = [
      Language(id: 1, code: 'en', name: 'English', flag: null, isActive: true),
    ];
    _selectedLanguageId = 1;
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> loadGamesByLanguage(int languageId) async {
    _isLoading = true;
    notifyListeners();
    _games = [
      Game(
        id: 1,
        title: 'Test Game',
        description: 'desc',
        gameType: 'quiz',
        languageId: languageId,
        difficulty: 1,
        maxScore: 100,
        thumbnailUrl: null,
        isActive: true,
        createdAt: DateTime.now(),
      )
    ];
    _isLoading = false;
    notifyListeners();
  }
}

void main() {
  testWidgets('GamesListScreen smoke test', (WidgetTester tester) async {
    final provider = TestGameProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(home: GamesListScreen()),
      ),
    );

    // allow post-frame callback in initState to run and populate
    await tester.pumpAndSettle();

    expect(find.text('Jeux'), findsOneWidget);
  });
}
