import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/xp_provider.dart';
import 'utils/constants.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final xpProvider = context.watch<XPProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            title: 'Progression',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressRow('XP total', xpProvider.totalXP.toString()),
                _buildProgressRow('Streak', '${xpProvider.streak} jours'),
                _buildProgressRow(
                  'Objectif quotidien',
                  '${xpProvider.dailyXP}/${xpProvider.dailyGoal} XP',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'Historique récent',
            child: xpProvider.history.isEmpty
                ? const Text('Aucune session enregistrée pour le moment.')
                : Column(
                    children: xpProvider.history
                        .map((entry) => ListTile(
                              leading: const Icon(Icons.bolt, color: AppColors.primary),
                              title: Text(entry.activity),
                              subtitle: Text(entry.date.toLocal().toString().substring(0, 16)),
                              trailing: Text('+${entry.xp} XP'),
                            ))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'Badges',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: xpProvider.badges
                  .map(
                    (badge) => Container(
                      width: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: badge.isUnlocked ? AppColors.secondary.withOpacity(0.2) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: badge.isUnlocked ? AppColors.secondary : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            badge.isUnlocked ? Icons.emoji_events : Icons.lock,
                            color: badge.isUnlocked ? AppColors.secondary : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badge.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            badge.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

