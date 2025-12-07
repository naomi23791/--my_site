import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/content_provider.dart';
import '../services/audio_feedback_service.dart';
import 'utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSetupScreen extends StatefulWidget {
  const LanguageSetupScreen({super.key});

  @override
  State<LanguageSetupScreen> createState() => _LanguageSetupScreenState();
}

class _LanguageSetupScreenState extends State<LanguageSetupScreen> {
  int _step = 0;
  String? _nativeLanguage;
  final Set<String> _learningLanguages = {};
  int _testQuestionIndex = 0;
  String? _selectedAnswer;
  int _testScore = 0;
  bool _saving = false;

  final List<Map<String, dynamic>> _testQuestions = const [
    {
      'question': 'Traduisez "Hello"',
      'options': ['Bonjour', 'Merci', 'Au revoir', 'Oui'],
      'correct': 'Bonjour',
    },
    {
      'question': 'Traduisez "Thank you"',
      'options': ['Merci', 'Pomme', 'Pain', 'Eau'],
      'correct': 'Merci',
    },
  ];

  @override
  void initState() {
    super.initState();
    context.read<ContentProvider>().loadLocalContent();
  }

  bool get _canContinue {
    if (_step == 0) return _nativeLanguage != null;
    if (_step == 1) return _learningLanguages.isNotEmpty;
    return true;
  }

  Future<void> _finishSetup() async {
    if (_learningLanguages.isEmpty) return;
    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_setup_complete', true);
    await prefs.setString('native_language', _nativeLanguage!);
    await prefs.setStringList('learning_languages', _learningLanguages.toList());

    final gameProvider = context.read<GameProvider>();
    final profileProvider = context.read<ProfileProvider>();

    await gameProvider.loadLanguages();
    final langIds = gameProvider.languages
        .where((lang) => _learningLanguages.contains(lang.name))
        .map((lang) => lang.id)
        .toList();
    if (langIds.isNotEmpty) {
      await gameProvider.persistSelectedLanguages(langIds);
      await gameProvider.loadGamesByLanguage(langIds.first);
    }

    try {
      await profileProvider.updateProfile(selectedLanguages: langIds);
    } catch (_) {}

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _selectAnswer(String option) async {
    setState(() => _selectedAnswer = option);
    final correct = _testQuestions[_testQuestionIndex]['correct'] == option;
    if (correct) {
      _testScore++;
      await AudioFeedbackService.instance.playCorrectSound();
    } else {
      await AudioFeedbackService.instance.playErrorSound();
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (_testQuestionIndex < _testQuestions.length - 1) {
      setState(() {
        _testQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _step = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration des langues'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _saving
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepHeader(),
                    const SizedBox(height: 24),
                    Expanded(child: _buildStepContent()),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_step > 0)
                          TextButton(
                            onPressed: () => setState(() => _step--),
                            child: const Text('Retour'),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _canContinue
                              ? () {
                                  if (_step < 2) {
                                    setState(() => _step++);
                                  } else {
                                    _finishSetup();
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(_step < 2 ? 'Continuer' : 'Terminer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStepHeader() {
    const steps = ['Langue maternelle', 'Langues à apprendre', 'Test rapide', 'Terminé'];
    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index <= _step;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: isActive ? AppColors.primary : Colors.grey.shade300,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: isActive ? Colors.white : Colors.black54),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? AppColors.primary : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildLanguageList(
          title: 'Choisissez votre langue maternelle',
          options: const ['Français', 'English', 'Español', 'Deutsch', 'Italiano'],
          selected: _nativeLanguage,
          onSelect: (value) => setState(() => _nativeLanguage = value),
          multiSelect: false,
        );
      case 1:
        return _buildLanguageList(
          title: 'Langues à apprendre',
          options: const ['Anglais', 'Espagnol', 'Allemand', 'Italien'],
          selectedSet: _learningLanguages,
          onToggle: (value) {
            setState(() {
              if (_learningLanguages.contains(value)) {
                _learningLanguages.remove(value);
              } else {
                _learningLanguages.add(value);
              }
            });
          },
          multiSelect: true,
        );
      case 2:
        return _buildTest();
      default:
        return _buildSummary();
    }
  }

  Widget _buildLanguageList({
    required String title,
    required List<String> options,
    String? selected,
    Set<String>? selectedSet,
    required bool multiSelect,
    void Function(String value)? onSelect,
    void Function(String value)? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = multiSelect ? selectedSet?.contains(option) ?? false : selected == option;
              return Card(
                child: ListTile(
                  title: Text(option),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  onTap: () {
                    if (multiSelect) {
                      onToggle?.call(option);
                    } else {
                      onSelect?.call(option);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTest() {
    final question = _testQuestions[_testQuestionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'] as String,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...List.generate((question['options'] as List).length, (index) {
          final option = (question['options'] as List)[index] as String;
          final isSelected = _selectedAnswer == option;
          return Card(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            child: ListTile(
              title: Text(option),
              onTap: _selectedAnswer == null ? () => _selectAnswer(option) : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSummary() {
    final contentProvider = context.watch<ContentProvider>();
    final categories = contentProvider.getCategories('en');
    final previewEntries = categories.isNotEmpty ? categories.first.entries.take(3).toList() : [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tout est prêt !',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text('Langue maternelle : $_nativeLanguage'),
        Text('Langues étudiées : ${_learningLanguages.join(', ')}'),
        Text('Score du test : $_testScore/${_testQuestions.length}'),
        const SizedBox(height: 16),
        if (previewEntries.isNotEmpty) ...[
          const Text(
            'Exemples de vocabulaire',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...previewEntries.map(
            (entry) => Text('${entry.word} → ${entry.translation}'),
          ),
        ],
      ],
    );
  }
}

