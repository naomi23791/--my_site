import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:linguaplay_app/screens/games/quiz_screen.dart';
import 'package:linguaplay_app/providers/game_provider.dart';
import 'package:linguaplay_app/models/game_model.dart';

// Extend real GameProvider with test-friendly overrides
class TestGameProvider extends GameProvider {
  TestGameProvider(): super(apiService: null);

  Game? _testGame;

  void setTestGame(Game game) {
    _testGame = game;
    notifyListeners();
  }

  @override
  Game? get selectedGame => _testGame;

  @override
  Future<GameSession> startGame(int gameId) async {
    return GameSession(
      id: 1,
      userId: 1,
      gameId: gameId,
      score: 0,
      maxScore: 100,
      status: 'in_progress',
      startedAt: DateTime.now(),
      completedAt: null,
    );
  }
}

void main() {
  testWidgets('QuizScreen shows title and start button', (WidgetTester tester) async {
    final gp = TestGameProvider();
    gp.setTestGame(Game(
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
        value: gp,
        child: MaterialApp(
          home: const QuizScreen(),
          routes: {
            '/quiz': (_) => const QuizScreen(),
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Quiz'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
