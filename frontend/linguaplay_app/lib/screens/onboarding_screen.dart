import 'package:flutter/material.dart';
import 'language_selection_screen.dart';
import 'utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()));
    }
  }

  void _skip() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          TextButton(onPressed: _skip, child: const Text('Passer', style: TextStyle(color: Colors.white)))
        ],
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (idx) => setState(() => _page = idx),
        children: [
          _buildPage(
            title: 'Master New Languages',
            body: 'Learn while playing fun games with friends!',
            icon: Icons.videogame_asset,
          ),
          _buildPage(
            title: 'Choose Languages',
            body: 'Select language(s) to focus on in the app.',
            icon: Icons.language,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Row(
                children: List.generate(2, (i) => Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: _page == i ? 12 : 8,
                  height: _page == i ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _page == i ? Theme.of(context).primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
                onPressed: _next,
                child: Text(_page < 1 ? 'Suivant' : 'Continuer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({required String title, required String body, required IconData icon}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Icon(icon, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(body, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
