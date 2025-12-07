import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'utils/constants.dart';
import 'login_screen.dart';

class OnboardingDuolingoScreen extends StatefulWidget {
  const OnboardingDuolingoScreen({super.key});

  @override
  State<OnboardingDuolingoScreen> createState() => _OnboardingDuolingoScreenState();
}

class _OnboardingDuolingoScreenState extends State<OnboardingDuolingoScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Language selections
  String? _nativeLanguage;
  final Set<String> _learningLanguages = {};
  
  // Test de niveau
  bool _showLevelTest = false;
  int _testQuestionIndex = 0;
  String? _selectedAnswer;
  int _testScore = 0;
  
  final List<Map<String, dynamic>> _levelTestQuestions = [
    {
      'question': 'Comment dit-on "Bonjour" en anglais?',
      'options': ['Hello', 'Goodbye', 'Thank you', 'Please'],
      'correct': 'Hello',
    },
    {
      'question': 'Comment dit-on "Merci" en anglais?',
      'options': ['Hello', 'Thank you', 'Sorry', 'Yes'],
      'correct': 'Thank you',
    },
    {
      'question': 'Comment dit-on "Au revoir" en anglais?',
      'options': ['Hello', 'Goodbye', 'Good morning', 'Good night'],
      'correct': 'Goodbye',
    },
    {
      'question': 'Comment dit-on "S\'il vous plaît" en anglais?',
      'options': ['Please', 'Thank you', 'Sorry', 'Excuse me'],
      'correct': 'Please',
    },
    {
      'question': 'Comment dit-on "Oui" en anglais?',
      'options': ['No', 'Yes', 'Maybe', 'Sure'],
      'correct': 'Yes',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // After language selection, show level test option
      if (!_showLevelTest) {
        setState(() {
          _showLevelTest = true;
        });
      } else {
        _completeOnboarding();
      }
    }
  }

  void _skipLevelTest() {
    _completeOnboarding();
  }

  void _answerLevelTest(String answer) {
    setState(() {
      _selectedAnswer = answer;
      if (answer == _levelTestQuestions[_testQuestionIndex]['correct']) {
        _testScore++;
      }
    });
    
    // Auto-advance after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_testQuestionIndex < _levelTestQuestions.length - 1) {
        setState(() {
          _testQuestionIndex++;
          _selectedAnswer = null;
        });
      } else {
        // Test completed
        _completeOnboarding();
      }
    });
  }

  Future<void> _completeOnboarding() async {
    // Save language selections
    final gp = context.read<GameProvider>();
    await gp.loadLanguages();
    
    // Find language IDs and persist
    if (_learningLanguages.isNotEmpty) {
      final learningLangIds = gp.languages
          .where((lang) => _learningLanguages.contains(lang.name))
          .map((lang) => lang.id)
          .toList();
      
      if (learningLangIds.isNotEmpty) {
        await gp.persistSelectedLanguages(learningLangIds);
        await gp.loadGamesByLanguage(learningLangIds.first);
      }
    }
    
    if (!mounted) return;
    
    // Navigate to login/register
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showLevelTest) {
      return _buildLevelTest();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (only on first page)
            if (_currentPage == 0)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _completeOnboarding(),
                  child: const Text(
                    'Passer',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            
            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue() ? _nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage < 2 ? 'Continuer' : 'Commencer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canContinue() {
    if (_currentPage == 0) return true;
    if (_currentPage == 1) return _nativeLanguage != null;
    if (_currentPage == 2) return _learningLanguages.isNotEmpty;
    return false;
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.language,
              size: 100,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Apprenez les langues\nen jouant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rendez l\'apprentissage amusant avec des jeux interactifs',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Quelle est votre langue maternelle?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildLanguageOption('Français', '🇫🇷', isNative: true),
                _buildLanguageOption('English', '🇬🇧', isNative: false),
                _buildLanguageOption('Español', '🇪🇸', isNative: false),
                _buildLanguageOption('Deutsch', '🇩🇪', isNative: false),
                _buildLanguageOption('Italiano', '🇮🇹', isNative: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    final learningLangs = ['Anglais', 'Espagnol', 'Allemand', 'Italien'];
    final flags = ['🇬🇧', '🇪🇸', '🇩🇪', '🇮🇹'];
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Quelle langue voulez-vous apprendre?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous pouvez en sélectionner plusieurs',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: List.generate(learningLangs.length, (index) {
                return _buildLanguageOption(
                  learningLangs[index],
                  flags[index],
                  isNative: false,
                  isMultiSelect: true,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    String name,
    String flag, {
    bool isNative = false,
    bool isMultiSelect = false,
  }) {
    final isSelected = isNative
        ? _nativeLanguage == name
        : _learningLanguages.contains(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 32)),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: () {
          setState(() {
            if (isNative) {
              _nativeLanguage = _nativeLanguage == name ? null : name;
            } else {
              if (_learningLanguages.contains(name)) {
                _learningLanguages.remove(name);
              } else {
                _learningLanguages.add(name);
              }
            }
          });
        },
      ),
    );
  }

  Widget _buildLevelTest() {
    if (_testQuestionIndex >= _levelTestQuestions.length) {
      return _buildTestResults();
    }

    final question = _levelTestQuestions[_testQuestionIndex];
    final isCorrect = _selectedAnswer != null &&
        _selectedAnswer == question['correct'];
    final showResult = _selectedAnswer != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Test de niveau (${_testQuestionIndex + 1}/5)'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              question['question'] as String,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: (question['options'] as List).length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final option = (question['options'] as List)[index] as String;
                  final isSelected = _selectedAnswer == option;
                  Color? bgColor;
                  
                  if (showResult) {
                    if (option == question['correct']) {
                      bgColor = AppColors.success.withOpacity(0.2);
                    } else if (isSelected && !isCorrect) {
                      bgColor = AppColors.error.withOpacity(0.2);
                    }
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: bgColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected && showResult
                            ? (isCorrect ? AppColors.success : AppColors.error)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: showResult && option == question['correct']
                              ? AppColors.success
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: showResult && option == question['correct']
                          ? const Icon(Icons.check_circle, color: AppColors.success)
                          : null,
                      onTap: showResult ? null : () => _answerLevelTest(option),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: _skipLevelTest,
                  child: const Text('Passer le test'),
                ),
                const Spacer(),
                if (showResult)
                  ElevatedButton(
                    onPressed: () {
                      if (_testQuestionIndex < _levelTestQuestions.length - 1) {
                        setState(() {
                          _testQuestionIndex++;
                          _selectedAnswer = null;
                        });
                      } else {
                        _completeOnboarding();
                      }
                    },
                    child: const Text('Suivant'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    final percentage = (_testScore / _levelTestQuestions.length * 100).round();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Résultats du test'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: AppColors.accent),
            const SizedBox(height: 24),
            Text(
              'Score: $_testScore/${_levelTestQuestions.length}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage% de bonnes réponses',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

