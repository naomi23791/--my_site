import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<MemoryCard> _cards = [];
  List<int> _flippedIndices = [];
  int _matches = 0;
  int _score = 0;
  int _timeRemaining = 120; // 2 minutes
  Timer? _timer;
  bool _gameStarted = false;
  bool _gameFinished = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Create pairs of cards (8 pairs = 16 cards)
    final emojis = ['🎨', '🎵', '🎭', '🎪', '🎬', '🎤', '🎸', '🎹'];
    _cards = [];
    for (int i = 0; i < emojis.length; i++) {
      _cards.add(MemoryCard(id: i * 2, emoji: emojis[i], isFlipped: false, isMatched: false));
      _cards.add(MemoryCard(id: i * 2 + 1, emoji: emojis[i], isFlipped: false, isMatched: false));
    }
    _cards.shuffle();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _timeRemaining = 120;
      _matches = 0;
      _score = 0;
      _flippedIndices = [];
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          timer.cancel();
          _finishGame();
        }
      });
    });
  }

  void _flipCard(int index) {
    if (_flippedIndices.length >= 2 || _cards[index].isFlipped || _cards[index].isMatched) {
      return;
    }

    setState(() {
      _cards[index].isFlipped = true;
      _flippedIndices.add(index);
    });

    if (_flippedIndices.length == 2) {
      Timer(const Duration(milliseconds: 1000), () {
        _checkMatch();
      });
    }
  }

  void _checkMatch() {
    final firstIndex = _flippedIndices[0];
    final secondIndex = _flippedIndices[1];

    if (_cards[firstIndex].emoji == _cards[secondIndex].emoji) {
      // Match!
      setState(() {
        _cards[firstIndex].isMatched = true;
        _cards[secondIndex].isMatched = true;
        _matches++;
        _score += 10;
      });

      if (_matches == 8) {
        _finishGame();
      }
    } else {
      // No match - flip back
      setState(() {
        _cards[firstIndex].isFlipped = false;
        _cards[secondIndex].isFlipped = false;
      });
    }

    setState(() {
      _flippedIndices = [];
    });
  }

  void _finishGame() {
    _timer?.cancel();
    setState(() {
      _gameFinished = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Memory Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar and timer
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _matches / 8,
                          minHeight: 8,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_matches/12',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${_timeRemaining}s',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Game board
          Expanded(
            child: _gameFinished
                ? _buildFinishedScreen()
                : _gameStarted
                    ? _buildGameBoard()
                    : _buildStartScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.memory, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            'Memory Game',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Match pairs of cards to win!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'Start Game',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return _buildCard(card, index);
        },
      ),
    );
  }

  Widget _buildCard(MemoryCard card, int index) {
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: card.isFlipped || card.isMatched
              ? Colors.white
              : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.isMatched
                ? AppColors.success
                : AppColors.textSecondary.withOpacity(0.3),
            width: card.isMatched ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: card.isFlipped || card.isMatched
              ? Text(
                  card.emoji,
                  style: const TextStyle(fontSize: 32),
                )
              : const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 32,
                ),
        ),
      ),
    );
  }

  Widget _buildFinishedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: AppColors.accent),
            const SizedBox(height: 24),
            const Text(
              '🎉 Game Finished!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _initializeGame();
                _startGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Play Again',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Games'),
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryCard {
  final int id;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.emoji,
    required this.isFlipped,
    required this.isMatched,
  });
}

