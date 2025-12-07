import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../utils/constants.dart';
import '../../widgets/game_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../providers/xp_provider.dart';
import '../../providers/content_provider.dart';

class HomeScreenDuolingo extends StatefulWidget {
  const HomeScreenDuolingo({super.key});

  @override
  State<HomeScreenDuolingo> createState() => _HomeScreenDuolingoState();
}

class _HomeScreenDuolingoState extends State<HomeScreenDuolingo> {
  int _currentIndex = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadLocalContent();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/games');
        break;
      case 2:
        Navigator.pushNamed(context, '/stats');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('LinguaPlay'),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Objectif Quotidien + Streak
            _buildDailyGoal(),
            const SizedBox(height: 24),
            // Arbre de compétences
            _buildSkillTree(),
            const SizedBox(height: 24),
            _buildContentHighlights(),
            const SizedBox(height: 24),
            // Section Jouer
            _buildPlaySection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildDailyGoal() {
    return Consumer<XPProvider>(
      builder: (context, xpProvider, _) {
        if (xpProvider.isDailyGoalReached && _confettiController.state == ConfettiControllerState.stopped) {
          _confettiController.play();
        }
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Objectif Quotidien',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Streak
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${xpProvider.streak}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar
              Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: xpProvider.dailyProgress.clamp(0.0, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${xpProvider.dailyXP} / ${xpProvider.dailyGoal} XP',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (xpProvider.isDailyGoalReached)
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Objectif atteint!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
                ],
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 20,
              gravity: 0.2,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkillTree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Arbre de compétences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // Skills
        _buildSkillCard('Basics', 1, 5, Icons.abc, AppColors.primary),
        const SizedBox(height: 12),
        _buildSkillCard('Food', 0, 5, Icons.restaurant, AppColors.secondary),
        const SizedBox(height: 12),
        _buildSkillCard('Travel', 0, 5, Icons.flight, AppColors.accent),
      ],
    );
  }

  Widget _buildSkillCard(String name, int level, int maxLevel, IconData icon, Color color) {
    final progress = level / maxLevel;
    final isUnlocked = level > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? color : Colors.grey.shade300,
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked ? color.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? AppColors.textPrimary : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: isUnlocked ? color : Colors.grey,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Niveau $level',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: isUnlocked ? color : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildContentHighlights() {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, _) {
        if (!contentProvider.isLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = contentProvider.getCategories('en');
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }
        final firstCategory = categories.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contenu ${firstCategory.name}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...firstCategory.entries.take(3).map(
              (entry) => Card(
                child: ListTile(
                  title: Text(entry.word),
                  subtitle: Text(entry.translation),
                  trailing: Text(entry.example),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jouer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/games'),
              child: const GameCard(
                title: 'Quiz',
                icon: Icons.quiz,
                color: AppColors.primary,
                progress: 0.7,
              ),
            ),
            InkWell(
              onTap: () {
                // TODO: Navigate to memory game
              },
              child: const GameCard(
                title: 'Mémoire',
                icon: Icons.memory,
                color: AppColors.secondary,
                progress: 0.4,
              ),
            ),
            InkWell(
              onTap: () {
                // TODO: Navigate to listening game
              },
              child: const GameCard(
                title: 'Écoute',
                icon: Icons.headphones,
                color: AppColors.accent,
                progress: 0.9,
              ),
            ),
            InkWell(
              onTap: () {
                // TODO: Navigate to other games
              },
              child: const GameCard(
                title: 'Vocabulaire',
                icon: Icons.text_fields,
                color: AppColors.primary,
                progress: 0.6,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

