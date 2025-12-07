import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/profile_provider.dart';
import 'utils/constants.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final Set<int> _selected = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final gp = context.read<GameProvider>();
    try {
      await gp.loadLanguages();
      // Load persisted selections if any
      final persisted = await gp.loadPersistedSelectedLanguages();
      if (persisted.isNotEmpty) {
        _selected.addAll(persisted);
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _toggle(int id) {
    setState(() {
      if (_selected.contains(id)) _selected.remove(id); else _selected.add(id);
    });
  }

  Future<void> _continue() async {
    final gp = context.read<GameProvider>();
    final profile = context.read<ProfileProvider>();

    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner au moins une langue')));
      return;
    }

    // Use first selected language to load games as a quick flow
    await gp.loadGamesByLanguage(_selected.first);

    // If logged in, update profile
    try {
      await profile.updateProfile(selectedLanguages: _selected.toList());
    } catch (_) {
      // ignore if not authenticated — profile API may fail
    }

    // Persist selection locally as fallback
    await gp.persistSelectedLanguages(_selected.toList());

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary, 
        title: const Text('Sélectionnez une langue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Erreur: $_error'))
                : ListView.builder(
                    itemCount: gp.languages.length,
                    itemBuilder: (context, index) {
                      final l = gp.languages[index];
                      final selected = _selected.contains(l.id);
                      
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                        child: ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l.flag ?? '🏳️', // CORRIGÉ : l.flag (pas flagIcon)
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          title: Text(
                            l.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected ? AppColors.primary : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            l.code,
                            style: TextStyle(
                              color: selected ? AppColors.primary : Colors.grey,
                            ),
                          ),
                          trailing: selected
                              ? const Icon(Icons.check_circle, color: AppColors.success)
                              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                          onTap: () => _toggle(l.id),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, 
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: _continue,
            child: const Text(
              'CONTINUER', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}