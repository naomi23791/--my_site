import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:linguaplay_app/providers/game_provider.dart';
import 'package:linguaplay_app/screens/games/quiz_screen.dart';
import 'package:linguaplay_app/models/game_model.dart';
import 'package:linguaplay_app/services/api_service.dart';

// Fake ApiService to avoid network for tests
class FakeApiService extends ApiService {
  @override
  Future<GameSession> startGameSession(int gameId) async {
    return GameSession(
      id: 123,
      userId: 1,
      gameId: gameId,
      score: 0,
      maxScore: 100,
      status: 'in_progress',
      startedAt: DateTime.now(),
    );
  }

  @override
  Future<List<QuizQuestion>> getGameQuestions(int gameId) async {
    return [
      QuizQuestion(
        id: 1,
        gameId: gameId,
        question: 'Quelle est la couleur du ciel?',
        options: ['Bleu', 'Vert', 'Rouge'],
        correctAnswer: 'Bleu',
        explanation: null,
        order: 1,
      ),
      QuizQuestion(
        id: 2,
        gameId: gameId,
        question: '2 + 2 = ?',
        options: ['3', '4', '5'],
        correctAnswer: '4',
        explanation: null,
        order: 2,
      ),
    ];
  }
}

void main() {
  testWidgets('Quiz full flow works with fake API', (WidgetTester tester) async {
    final fakeApi = FakeApiService();
    final provider = GameProvider(apiService: fakeApi);

    // Provide a selected game to the provider so QuizScreen displays a title without network calls
    provider.setSelectedGame(Game(
      id: 1,
      title: 'Test Quiz',
      description: 'desc',
      gameType: 'quiz',
      languageId: 1,
      difficulty: 1,
      maxScore: 100,
      thumbnailUrl: null,
      isActive: true,
      createdAt: DateTime.now(),
    ));

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: MaterialApp(
          home: Builder(
            builder: (context) => QuizScreen(),
          ),
          onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => QuizScreen(), settings: RouteSettings(arguments: {'gameId': 1})),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Start button should appear
    expect(find.text('Démarrer le jeu'), findsOneWidget);

    await tester.tap(find.text('Démarrer le jeu'));
    await tester.pumpAndSettle();

    // First question visible
    expect(find.text('Quelle est la couleur du ciel?'), findsOneWidget);

    // Answer correct
    await tester.tap(find.text('Bleu'));
    await tester.pumpAndSettle();
    expect(find.text('Bonne réponse!'), findsOneWidget);

    // Next
    await tester.tap(find.text('Question suivante'));
    await tester.pumpAndSettle();

    // Second question
    expect(find.text('2 + 2 = ?'), findsOneWidget);

    // Answer incorrectly
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    expect(find.text('Mauvaise réponse.'), findsOneWidget);

    // Finish
    await tester.tap(find.text('Terminer et envoyer le score'));
    await tester.pumpAndSettle();

    // If no exceptions, consider test passed
    expect(true, isTrue);
  });
}
