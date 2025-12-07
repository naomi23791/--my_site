import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/xp_provider.dart';
import 'utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _dailyGoal = 50;
  bool _ambientSound = false;

  @override
  void initState() {
    super.initState();
    final xpProvider = context.read<XPProvider>();
    _dailyGoal = xpProvider.dailyGoal.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final xpProvider = context.watch<XPProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Objectif quotidien (XP)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _dailyGoal,
            min: 20,
            max: 100,
            divisions: 8,
            label: '${_dailyGoal.round()} XP',
            onChanged: (value) {
              setState(() => _dailyGoal = value);
            },
            onChangeEnd: (value) {
              xpProvider.setDailyGoal(value.round());
            },
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Ambiance sonore'),
            subtitle: const Text('Activer un léger son lors des succès'),
            value: _ambientSound,
            onChanged: (value) {
              setState(() => _ambientSound = value);
            },
          ),
          const SizedBox(height: 24),
          ListTile(
            title: const Text('Support & Feedback'),
            subtitle: const Text('contact@linguaplay.app'),
            leading: const Icon(Icons.email_outlined),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

