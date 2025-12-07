import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/xp_provider.dart';
import '../../services/audio_feedback_service.dart';
import '../utils/constants.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _started = false;
  Timer? _advanceTimer;
  Timer? _timer;
  int _timeRemaining = 60; // 60 secondes par défaut
  // session is kept in provider; no local use necessary

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _startGame(int gameId) async {
    final gp = context.read<GameProvider>();
    try {
      await gp.startGame(gameId);
      setState(() {
        _started = true;
        _timeRemaining = 60;
      });
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur démarrage: $e')));
    }
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
          // Time's up - auto finish
        }
      });
    });
  }

  Future<void> _loadQuestions(int gameId) async {
    final gp = context.read<GameProvider>();
    await gp.loadQuestions(gameId);
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final game = gp.selectedGame;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final gameIdFromArgs = args?['gameId'] as int?;
    final gameId = gameIdFromArgs ?? game?.id;

    // Get language name from languageId
    String languageName = 'English';
    if (game != null && gp.languages.isNotEmpty) {
      final language = gp.languages.firstWhere(
        (lang) => lang.id == game.languageId,
        orElse: () => gp.languages.first,
      );
      languageName = language.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${game?.title ?? 'Quiz'} - $languageName'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_started) ...[
              ElevatedButton(
                onPressed: gameId == null ? null : () async {
                  await _startGame(gameId);
                  await _loadQuestions(gameId);
                },
                child: const Text('Démarrer le jeu'),
              ),
            ] else ...[
              // Quiz UI
              Builder(builder: (ctx) {
                final gp = context.watch<GameProvider>();
                if (gp.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (gp.questions.isEmpty) {
                  return const Center(child: Text('Aucune question disponible.'));
                }

                final cq = gp.currentQuestion;
                if (cq == null) {
                  // Finished
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 64, color: AppColors.success),
                        const SizedBox(height: 16),
                        Text(
                          'Partie terminée!',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Score: ${gp.currentScore}/${gp.questions.length}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            final finished = await gp.finishCurrentGame();
                            if (!mounted) return;
                            if (finished != null) {
                              Navigator.pushReplacementNamed(context, '/result');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Échec envoi score')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text('Voir les résultats', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }

                final progress = (gp.currentQuestionIndex + 1) / gp.questions.length;
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress bar and timer
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: AppColors.background,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${gp.currentQuestionIndex + 1}/${gp.questions.length}',
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
                      const SizedBox(height: 32),
                      // Question
                      Text(
                        cq.question,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Answer options
                      Expanded(
                        child: ListView.separated(
                          itemCount: cq.options.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final opt = cq.options[index];
                            Color? bgColor;
                            Color? textColor;
                            IconData? icon;
                            
                            if (gp.answered) {
                              if (opt == gp.lastSelectedOption) {
                                if (gp.lastAnswerCorrect == true) {
                                  bgColor = AppColors.success;
                                  textColor = Colors.white;
                                  icon = Icons.check_circle;
                                } else {
                                  bgColor = AppColors.error;
                                  textColor = Colors.white;
                                  icon = Icons.cancel;
                                }
                              } else if (opt == cq.correctAnswer) {
                                bgColor = AppColors.success.withOpacity(0.3);
                                textColor = AppColors.textPrimary;
                                icon = Icons.check_circle;
                              }
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: bgColor ?? Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: bgColor != null
                                      ? Colors.transparent
                                      : AppColors.textSecondary.withOpacity(0.3),
                                ),
                                boxShadow: bgColor == null
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: gp.answered
                                      ? null
                                      : () async {
                                          await gp.submitAnswer(opt);
                                          
                                          // Add XP if correct
                                          if (gp.lastAnswerCorrect == true) {
                                            final xpProvider = context.read<XPProvider>();
                                            await xpProvider.addXP(10, activity: 'Quiz');
                                            await AudioFeedbackService.instance.playCorrectSound();
                                            _showXPPopup(context, 10, true);
                                          } else {
                                            await AudioFeedbackService.instance.playErrorSound();
                                            _showXPPopup(context, 0, false);
                                          }
                                          
                                          _advanceTimer?.cancel();
                                          _advanceTimer = Timer(const Duration(seconds: 2), () async {
                                            if (!mounted) return;
                                            final provider = context.read<GameProvider>();
                                            final isLast = provider.currentQuestionIndex >=
                                                provider.questions.length - 1;
                                            if (!provider.answered) return;
                                            if (!isLast) {
                                              provider.nextQuestion();
                                            } else {
                                              final finished = await provider.finishCurrentGame();
                                              if (!mounted) return;
                                              if (finished != null) {
                                                // Add bonus XP for completing
                                                final xpProvider = context.read<XPProvider>();
                                                final bonusXP = provider.currentScore * 5;
                                                await xpProvider.addXP(bonusXP, activity: 'Quiz - Bonus');
                                                
                                                Navigator.pushReplacementNamed(context, '/result');
                                              }
                                            }
                                          });
                                        },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        if (icon != null) ...[
                                          Icon(icon, color: textColor, size: 24),
                                          const SizedBox(width: 12),
                                        ],
                                        Expanded(
                                          child: Text(
                                            opt,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: textColor ?? AppColors.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Feedback and actions
                      if (gp.answered) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: gp.lastAnswerCorrect == true
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                gp.lastAnswerCorrect == true ? Icons.check_circle : Icons.cancel,
                                color: gp.lastAnswerCorrect == true
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                gp.lastAnswerCorrect == true ? 'Bonne réponse!' : 'Mauvaise réponse.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: gp.lastAnswerCorrect == true
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        TextButton.icon(
                          onPressed: () {
                            // Skip question
                            if (gp.currentQuestionIndex < gp.questions.length - 1) {
                              gp.nextQuestion();
                            }
                          },
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Skip Question'),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _showXPPopup(BuildContext context, int xp, bool isCorrect) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _XPPopupOverlay(
        xp: xp,
        isCorrect: isCorrect,
        onComplete: () {
          overlayEntry.remove();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto-remove after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}

class _XPPopupOverlay extends StatefulWidget {
  final int xp;
  final bool isCorrect;
  final VoidCallback onComplete;

  const _XPPopupOverlay({
    required this.xp,
    required this.isCorrect,
    required this.onComplete,
  });

  @override
  State<_XPPopupOverlay> createState() => _XPPopupOverlayState();
}

class _XPPopupOverlayState extends State<_XPPopupOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: SlideTransition(
            position: _offset,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.isCorrect
                      ? AppColors.success
                      : AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isCorrect ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isCorrect ? 'Excellent!' : 'Incorrect',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.xp > 0)
                          Text(
                            '+${widget.xp} XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
