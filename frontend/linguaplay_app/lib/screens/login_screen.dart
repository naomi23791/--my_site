import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_textfield.dart' as custom_field;
import 'utils/constants.dart';
import '../widgets/custom_button.dart' as custom_btn;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 32),
              
              // Formulaire
              _buildLoginForm(),
              const SizedBox(height: 24),
              
              // Bouton de connexion
              custom_btn.CustomButton(
                onPressed: authProvider.isLoading ? null : _login,
                text: authProvider.isLoading ? 'Connexion...' : 'Se connecter',
                icon: authProvider.isLoading ? null : Icons.login,
              ),
              const SizedBox(height: 16),
              
              // Lien vers inscription
              _buildRegisterLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.language,
            color: Colors.white,
            size: 60,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Bienvenue sur LinguaPlay',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Connectez-vous pour continuer votre aventure',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          custom_field.CustomTextField(
            controller: _usernameController,
            label: 'Nom d\'utilisateur',
            prefixIcon: Icons.person,
            keyboardType: TextInputType.text,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom d\'utilisateur';
              }
              if (value.length < 3) {
                return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          custom_field.CustomTextField(
            controller: _passwordController,
            label: 'Mot de passe',
            prefixIcon: Icons.lock,
            obscureText: true,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implémenter la réinitialisation du mot de passe
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                    backgroundColor: AppColors.textSecondary,
                  ),
                );
              },
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Nouveau sur LinguaPlay ? ',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: const Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );
      
      if (!mounted) return;
      
      if (authProvider.isAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        final completed = prefs.getBool('language_setup_complete') ?? false;
        Navigator.pushReplacementNamed(
          context,
          completed ? '/home' : '/language-setup',
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}