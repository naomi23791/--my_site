import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class VocabEntry {
  final String word;
  final String translation;
  final String example;

  VocabEntry({
    required this.word,
    required this.translation,
    required this.example,
  });

  factory VocabEntry.fromJson(Map<String, dynamic> json) {
    return VocabEntry(
      word: json['word'] as String,
      translation: json['translation'] as String,
      example: json['example'] as String? ?? '',
    );
  }
}

class VocabCategory {
  final String name;
  final List<VocabEntry> entries;

  VocabCategory({required this.name, required this.entries});
}

class ContentProvider with ChangeNotifier {
  bool _isLoaded = false;
  final Map<String, List<VocabCategory>> _contentByLanguage = {};
  String? _error;

  bool get isLoaded => _isLoaded;
  String? get error => _error;

  Future<void> loadLocalContent() async {
    if (_isLoaded) return;

    try {
      final rawJson = await rootBundle.loadString('assets/data/vocab_en.json');
      final decoded = json.decode(rawJson) as Map<String, dynamic>;
      final languages = decoded['languages'] as Map<String, dynamic>;

      languages.forEach((langCode, langData) {
        final categories = (langData['categories'] as Map<String, dynamic>).entries.map((entry) {
          final entries = (entry.value as List<dynamic>)
              .map((item) => VocabEntry.fromJson(item as Map<String, dynamic>))
              .toList();
          return VocabCategory(name: entry.key, entries: entries);
        }).toList();

        _contentByLanguage[langCode] = categories;
      });

      _isLoaded = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  List<VocabCategory> getCategories(String languageCode) {
    return _contentByLanguage[languageCode] ?? [];
  }

  List<VocabEntry> getEntriesForCategory(String languageCode, String categoryName) {
    final categories = getCategories(languageCode);
    final category = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => VocabCategory(name: categoryName, entries: const []),
    );
    return category.entries;
  }
}

