import 'package:flutter/material.dart';
import 'utils/constants.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Refresh leaderboard
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'This Week'),
            Tab(text: '🏆 All Time'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardList(isWeekly: true),
          _buildLeaderboardList(isWeekly: false),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList({required bool isWeekly}) {
    // Mock data - à remplacer par les vraies données du backend
    final entries = [
      _LeaderboardEntry(rank: 1, name: 'Anna', points: 2340, language: '🇬🇧 English', isCurrentUser: false),
      _LeaderboardEntry(rank: 2, name: 'Marco', points: 1850, language: '🇪🇸 Spanish', isCurrentUser: false),
      _LeaderboardEntry(rank: 3, name: 'Sophie', points: 1620, language: '🇫🇷 French', isCurrentUser: false),
      _LeaderboardEntry(rank: 4, name: 'Emma', points: 980, language: '🇩🇪 German', isCurrentUser: false),
      _LeaderboardEntry(rank: 5, name: 'Lucas', points: 850, language: '🇳🇱 Dutch', isCurrentUser: false),
      // ... more entries
      _LeaderboardEntry(rank: 42, name: 'You', points: 850, language: '🇬🇧 English', isCurrentUser: true),
    ];

    return Column(
      children: [
        // Your rank info bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.primary.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Your Rank: #42 • 850 pts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        // Leaderboard list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildLeaderboardItem(entry);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(_LeaderboardEntry entry) {
    Color? backgroundColor;
    IconData? medalIcon;
    Color? medalColor;

    if (entry.rank == 1) {
      backgroundColor = Colors.amber.withOpacity(0.1);
      medalIcon = Icons.workspace_premium;
      medalColor = Colors.amber;
    } else if (entry.rank == 2) {
      backgroundColor = Colors.grey.withOpacity(0.1);
      medalIcon = Icons.workspace_premium;
      medalColor = Colors.grey;
    } else if (entry.rank == 3) {
      backgroundColor = Colors.brown.withOpacity(0.1);
      medalIcon = Icons.workspace_premium;
      medalColor = Colors.brown;
    }

    if (entry.isCurrentUser) {
      backgroundColor = AppColors.primary.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: entry.isCurrentUser
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Row(
              children: [
                if (medalIcon != null)
                  Icon(medalIcon, color: medalColor, size: 24)
                else
                  Text(
                    '${entry.rank}.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: entry.isCurrentUser
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              entry.name[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and language
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (entry.isCurrentUser) ...[
                      const Icon(Icons.person, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      entry.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: entry.isCurrentUser
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.language,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.points}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: entry.isCurrentUser
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              if (entry.isCurrentUser)
                const Icon(Icons.star, color: AppColors.accent, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntry {
  final int rank;
  final String name;
  final int points;
  final String language;
  final bool isCurrentUser;

  _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.points,
    required this.language,
    required this.isCurrentUser,
  });
}

