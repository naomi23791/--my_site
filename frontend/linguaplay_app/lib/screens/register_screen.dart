import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart'; // GARDEZ cette ligne
import '../widgets/custom_textfield.dart' as custom_field;
import 'utils/constants.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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
              _buildRegisterForm(),
              const SizedBox(height: 24),
              
              // Bouton d'inscription
              CustomButton( // Utilisez directement la classe
                onPressed: authProvider.isLoading ? null : _register,
                text: authProvider.isLoading ? 'Inscription...' : 'Créer mon compte',
                icon: authProvider.isLoading ? null : Icons.arrow_forward,
              ),
              const SizedBox(height: 16),
              
              // Lien vers connexion
              _buildLoginLink(context),
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
          'Rejoignez LinguaPlay',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Commencez votre aventure linguistique',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          custom_field.CustomTextField(
            controller: _usernameController,
            label: 'Nom d\'utilisateur',
            prefixIcon: Icons.person,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nom d\'utilisateur';
              }
              if (value.length < 3) {
                return 'Le nom doit contenir au moins 3 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          custom_field.CustomTextField(
            controller: _emailController,
            label: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Veuillez entrer un email valide';
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
                return 'Veuillez entrer un mot de passe';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Déjà un compte ? ',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: const Text(
            'Se connecter',
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.register(
        _usernameController.text,
        _emailController.text,
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