// reset_auth.dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> resetAuth() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  print('✅ Token supprimé - Redémarrez l\'app');
}