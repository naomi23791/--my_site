# 🔧 Guide d'Installation et Commandes – LinguaPlay

## 📦 Pré-requis

Assurez-vous que vous avez installé:

```bash
# Flutter SDK (3.10+)
flutter --version

# Android Studio / Xcode (pour emulateurs)
flutter doctor

# Node.js (optionnel, pour Firebase)
node --version
```

---

## ⚙️ Setup projet

### 1. Cloner et configurer

```bash
# Cloner le repo
git clone <repo-url> my_site
cd my_site/frontend/linguaplay_app

# Mettre à jour Flutter
flutter upgrade

# Récupérer les dépendances actuelles
flutter pub get
```

### 2. Vérifier l'environnement

```bash
# Diagnostic complet
flutter doctor

# Doit afficher ✓ pour:
# [✓] Flutter (Channel stable, ...)
# [✓] Android toolchain
# [✓] Xcode (si macOS/iOS)
# [✓] VS Code
```

### 3. Mettre à jour pubspec.yaml

Remplacer le contenu `pubspec.yaml` par:

```yaml
name: linguaplay_app
description: "LinguaPlay - Apprenez les langues en jouant"

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.10.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Networking & Storage
  http: ^1.1.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI & Design
  google_fonts: ^6.1.0
  intl: ^0.19.0
  cupertino_icons: ^1.0.2
  confetti: ^0.7.0
  lottie: ^2.6.0
  
  # Navigation
  go_router: ^14.0.0
  
  # Firebase (optionnel pour Phase 2)
  # firebase_core: ^25.0.0
  # firebase_messaging: ^14.7.0
  # firebase_analytics: ^11.0.0
  
  # Misc
  uuid: ^4.0.0
  timeago: ^3.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.0
  build_runner: ^2.4.0

flutter:
  uses-material-design: true
  
  # Assets
  assets:
    - assets/icons/
    - assets/images/
    
  # Fonts
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
    - family: OpenSans
      fonts:
        - asset: assets/fonts/OpenSans-Regular.ttf
        - asset: assets/fonts/OpenSans-SemiBold.ttf
          weight: 600
```

Puis:

```bash
flutter pub get
```

---

## 🚀 Commandes de développement

### Lancer l'app

```bash
# En développement (hot reload)
flutter run

# Sur device spécifique
flutter run -d <device-id>
flutter devices  # Lister devices disponibles

# Mode release
flutter run --release

# Avec arguments
flutter run --flavor dev  # Si flavors configurés
```

### Analyser le code

```bash
# Lint/analyze
flutter analyze

# Format code
flutter format lib/

# Fixer issues automatiquement (Dart fixes)
dart fix --apply

# Afficher warnings detaillés
flutter analyze --verbose
```

### Tests

```bash
# Tests unitaires
flutter test

# Tests avec coverage
flutter test --coverage

# Tests spécifiques
flutter test test/providers/auth_provider_test.dart

# Tests widgets
flutter test test/widgets/

# Afficher coverage rapport (Linux/macOS)
# Générer et ouvrir coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Performance & Debugging

```bash
# Profiler (hot mode)
flutter run --profile

# Trace performance
flutter run --trace-startup  # Affiche startup time

# DevTools (inspect UI en temps réel)
flutter pub global activate devtools
devtools

# Avec run, puis cliquer sur lien pour DevTools
flutter run --debug

# Memory profiler
flutter run --profile
# Dans DevTools: Memory tab
```

---

## 📱 Emulateurs / Devices

### Android

```bash
# Lancer emulateur Android
emulator -avd <name>

# Créer AVD
android create avd -n "Pixel_5_API_31" -t android-31 -k "default"

# Lister devices connectés
adb devices

# Installer APK
flutter install

# Uninstall
flutter uninstall
```

### iOS (macOS seulement)

```bash
# Lancer simulateur
open -a Simulator

# Installer
flutter run -d <simulator-id>

# iOS device (connecté)
flutter run -d <device-id>

# Voir logs (device réel)
idevicename
```

---

## 🔌 Configuration Backend

### Modifier URL API

Fichier : `lib/services/api_service.dart`

```dart
class ApiService {
  // Développement local
  static const String baseUrl = "http://10.0.2.2:8000/api";  // Android emulator
  // static const String baseUrl = "http://localhost:8000/api";  // iOS simulator
  // static const String baseUrl = "http://192.168.1.X:8000/api";  // Device physique (remplacer X)
  
  // Production
  // static const String baseUrl = "https://api.linguaplay.com/api";
}
```

### Vérifier backend

```bash
# Depuis le répertoire backend (my_site)
cd ../../my_site

# Installer dependencies Python
pip install -r requirements.txt  # Si existe

# Lancer Django dev server
python manage.py runserver 0.0.0.0:8000

# En parallèle (autre terminal)
cd frontend/linguaplay_app
flutter run
```

### Tester API endpoints

```bash
# Avec curl
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"pass"}'

# Avec Postman (télécharger Postman, importer collection backend)
# OU utiliser l'API dans navigateur (GET requests)
curl http://localhost:8000/api/games/
curl http://localhost:8000/api/challenges/
```

---

## 📂 Structure générale

```
linguaplay_app/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── config/
│   │   └── api_config.dart
│   ├── models/
│   │   ├── auth_models.dart         # ✅ Existant
│   │   ├── game_models.dart         # 🔄 À créer
│   │   ├── challenge_models.dart    # 🔄 À créer
│   │   ├── profile_models.dart      # 🔄 À créer
│   │   └── reward_models.dart       # 🔄 À créer
│   ├── providers/
│   │   ├── auth_provider.dart       # ✅ Existant (améliorer)
│   │   ├── game_provider.dart       # 🔄 À créer
│   │   ├── challenge_provider.dart  # 🔄 À créer
│   │   ├── profile_provider.dart    # 🔄 À créer
│   │   └── social_provider.dart     # 🔄 À créer
│   ├── services/
│   │   ├── api_service.dart         # ✅ Existant (améliorer)
│   │   ├── auth_service.dart        # À créer
│   │   └── storage_service.dart     # À créer
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart    # ✅ Existant
│   │   │   └── register_screen.dart # ✅ Existant
│   │   ├── onboarding/              # À créer
│   │   ├── games/                   # À créer
│   │   ├── profile/                 # À créer
│   │   ├── challenges/              # À créer
│   │   ├── social/                  # À créer
│   │   └── home/
│   │       └── home_screen.dart     # ✅ Existant
│   ├── widgets/
│   │   ├── custom_button.dart       # ✅ Existant
│   │   ├── custom_textfield.dart    # ✅ Existant
│   │   └── ... (autres widgets)
│   └── utils/
│       ├── constants.dart           # ✅ Existant
│       ├── formatters.dart          # À créer
│       ├── validators.dart          # À créer
│       └── extensions.dart          # À créer
│
├── test/
│   ├── unit/
│   │   ├── models_test.dart
│   │   ├── providers_test.dart
│   │   └── services_test.dart
│   └── widget/
│       └── screens_test.dart
│
├── pubspec.yaml                    # À mettre à jour
├── analysis_options.yaml            # ✅ Existant
└── README.md
```

---

## ✅ Checklist avant chaque commit

```bash
# 1. Vérifier le code
flutter analyze

# 2. Formater
flutter format lib/

# 3. Tests
flutter test

# 4. Build
flutter build apk --debug  # Android test
flutter build ios --no-codesign  # iOS test (macOS)

# 5. Commit
git add .
git commit -m "feat: <description>"
git push origin <branch>
```

---

## 🛠️ Troubleshooting courant

### ❌ "Gradle build failed" (Android)

```bash
# Clean build
flutter clean
rm -rf android/.gradle
flutter pub get
flutter build apk
```

### ❌ "Pod install failed" (iOS)

```bash
# iOS cleanup
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..
flutter run
```

### ❌ "Device offline"

```bash
# Reconnect
flutter clean
adb reconnect  # Android
# OR
unplug/replug device
```

### ❌ "Port 8000 already in use" (Backend)

```bash
# Lancer sur port différent
python manage.py runserver 0.0.0.0:8001

# Puis mettre à jour ApiService:
# static const String baseUrl = "http://localhost:8001/api";
```

### ❌ "Connection refused" (API)

```bash
# Vérifier backend tourne
curl http://localhost:8000/api/

# Vérifier URL dans ApiService (10.0.2.2 pour Android emulator)
# Vérifier firewall/CORS
# Backend settings.py: ALLOWED_HOSTS = ['*']
```

### ❌ "State is not defined" (Provider)

```bash
# Vérifier que Consumer/Provider est wrappé au bon niveau
# Vérifier que provider est ajouté dans main.dart:
// MultiProvider(
//   providers: [
//     ChangeNotifierProvider(create: (_) => AuthProvider()),
//     ChangeNotifierProvider(create: (_) => GameProvider()),
//   ],
//   child: MyApp(),
// )
```

---

## 🚀 Préparation deployment

### Android Play Store

```bash
# Générer keystore
keytool -genkey -v -keystore ~/linguaplay-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias linguaplay

# Créer build release
flutter build appbundle --release

# Fichier: build/app/outputs/bundle/release/app-release.aab
# → Upload à Google Play Console
```

### iOS App Store

```bash
# Générer build release
flutter build ios --release

# Puis dans Xcode (à faire manuellement):
# 1. Open Runner.xcworkspace
# 2. Build → Generic iOS Device
# 3. Product → Archive
# 4. Distribute to App Store
```

### Web (optionnel)

```bash
# Build web
flutter build web

# Serveur local (tester)
python -m http.server --directory build/web 8000
# Accéder à http://localhost:8000

# Deploy à GitHub Pages / Netlify
# ... (instructions spécifiques selon host)
```

---

## 📊 Monitoring & Analytics

### Firebase (optionnel Phase 2)

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init

# Deploy
firebase deploy
```

### Logs en production

```bash
# Android logs
adb logcat -s flutter

# iOS logs (device)
ideviceSyslog

# Voir crashes
flutter run --verbose
```

---

## 📚 Ressources utiles

- **Flutter docs** : https://flutter.dev/docs
- **Provider docs** : https://pub.dev/packages/provider
- **Django REST** : https://www.django-rest-framework.org/
- **Figma** : https://www.figma.com/
- **GitHub** : https://github.com/

---

## 💡 Best practices

### Development workflow

```bash
# 1. Branch per feature
git checkout -b feature/quiz-game

# 2. Code + commit fréquent
# (commits atomiques, messages clairs)

# 3. Push et créer PR
git push origin feature/quiz-game

# 4. Code review + merge
# (via GitHub/GitLab interface)

# 5. Delete branch
git branch -d feature/quiz-game
```

### Testing discipline

```bash
# TDD approach pour providers
# 1. Écrire test (RED)
flutter test test/providers/game_provider_test.dart

# 2. Implémenter code (GREEN)
# (modifier game_provider.dart)

# 3. Refactor + commit (BLUE)
flutter test  # Tous les tests
```

---

## ℹ️ Support et questions

Pour toute question:

1. Consulter documentation officielle (links ci-dessus)
2. Chercher sur Stack Overflow
3. Poser question dans Discussions GitHub
4. Contacter équipe développement

---

**Date d'update** : 22 novembre 2025  
**Version** : 1.0  
**Status** : Ready for implementation

