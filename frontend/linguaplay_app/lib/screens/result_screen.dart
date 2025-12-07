import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/xp_provider.dart';
import 'utils/constants.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _getStars(int score, int total) {
    final percentage = score / total;
    if (percentage >= 0.9) return '⭐⭐⭐';
    if (percentage >= 0.7) return '⭐⭐';
    return '⭐';
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final total = gp.questions.length;
    final score = gp.currentScore;
    final wrong = total - score;
    final points = score * 10; // 10 points par bonne réponse
    final hasBadge = score == total; // Badge si score parfait

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Celebration icon
              ScaleTransition(
                scale: _scale,
                child: const Icon(
                  Icons.celebration,
                  size: 100,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              const Text(
                '🎉 Awesome Job!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              // Score with stars
              Text(
                'Score: $score/$total ${_getStars(score, total)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              // Points earned
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: AppColors.primary, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '+$points Points',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Streak and badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAchievementItem(
                    Icons.local_fire_department,
                    'Daily Streak +1',
                    AppColors.accent,
                  ),
                  if (hasBadge) ...[
                    const SizedBox(width: 16),
                    _buildAchievementItem(
                      Icons.emoji_events,
                      'Earned Badge!',
                      AppColors.accent,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              // Performance stats
              const Text(
                '📊 Performance:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow('Correct:', '$score', AppColors.success),
              const SizedBox(height: 8),
              _buildStatRow('Wrong:', '$wrong', AppColors.error),
              const SizedBox(height: 8),
              _buildStatRow('Time:', '3m 20s', AppColors.textSecondary),
              const SizedBox(height: 8),
              _buildStatRow('Avg Speed:', '20s/Q', AppColors.textSecondary),
              const SizedBox(height: 32),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Share on social
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Partage à venir')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Partager'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/games');
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Suivant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/games');
                },
                child: const Text('← Back to Games'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementItem(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
