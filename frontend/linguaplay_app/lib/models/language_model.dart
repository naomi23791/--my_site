// frontend/linguaplay_app/lib/models/language_model.dart

class Language {
  final int id;
  final String name;
  final String code;
  final String flagIcon;

  Language({
    required this.id,
    required this.name,
    required this.code,
    required this.flagIcon,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      flagIcon: json['flag_icon'] ?? '🏳️', // Valeur par défaut
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'flag_icon': flagIcon,
    };
  }

  @override
  String toString() {
    return 'Language(id: $id, name: $name, code: $code)';
  }
}