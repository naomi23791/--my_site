# 🎯 Quick Reference Card – LinguaPlay

**Imprimez cette page ! 📄**

---

## 📚 5 Documents principaux

| # | Document | Pages | Temps | Pour qui ? |
|---|----------|-------|-------|-----------|
| 1 | RESUME_PROPOSITIONS_EXECUTIVE.md | 10 | 15 min | Stakeholders |
| 2 | GUIDE_IMPLEMENTATION_IMMEDIATE.md | 12 | 40 min | Developers |
| 3 | RAPPORT_AMELIORATIONS_LINGUAPLAY.md | 24 | 60 min | Tech leads |
| 4 | DESIGN_GUIDE_FIGMA_MOCKUPS.md | 15 | 45 min | Designers |
| 5 | GUIDE_INSTALLATION_COMMANDES.md | 10 | 30 min | DevOps/QA |

---

## ⚡ Démarrer en 5 min

```bash
# 1. Lancer backend Django
cd my_site
python manage.py runserver 0.0.0.0:8000

# 2. Lancer app Flutter
cd frontend/linguaplay_app
flutter pub get
flutter run

# 3. API disponible sur
http://localhost:8000/api/

# 4. App disponible sur
Emulator ou device physique
```

---

## 🛠️ Commandes Flutter rapides

```bash
flutter create .              # New project
flutter pub get               # Install deps
flutter run                   # Launch app
flutter run --release        # Production build
flutter analyze              # Check code quality
flutter format lib/          # Format code
flutter test                 # Run tests
flutter clean                # Full cleanup
flutter devices              # List devices
dart fix --apply             # Auto-fix issues
```

---

## 📂 Fichiers clés à modifier/créer

### À créer immédiatement
```
lib/models/game_models.dart             (1 jour)
lib/models/challenge_models.dart        (1 jour)
lib/models/profile_models.dart          (0.5 jour)
lib/models/reward_models.dart           (0.5 jour)
lib/providers/game_provider.dart        (1 jour)
lib/providers/challenge_provider.dart   (1 jour)
lib/providers/profile_provider.dart     (1 jour)
```

### À améliorer
```
lib/services/api_service.dart           (2-3 jours)
lib/providers/auth_provider.dart        (1 jour)
pubspec.yaml                            (0.5 jour)
lib/main.dart                           (0.5 jour)
```

### Nouvelles screens (Semaine 2)
```
lib/screens/onboarding/                 (2 jours)
lib/screens/games/quiz_screen.dart      (3 jours)
lib/screens/games/games_list_screen.dart (2 jours)
lib/screens/profile/profile_screen.dart (2 jours)
```

---

## 🎨 Design System (Mémoriser)

```
Primaire:    #3A86FF (Bleu)
Secondaire:  #83C5BE (Vert)
Accent:      #FF8C42 (Orange)
Fond:        #F8F9FA (Blanc cassé)
Texte:       #212529 (Noir)
Sous-texte:  #6C757D (Gris)
Erreur:      #DC3545 (Rouge)
```

---

## 📊 Roadmap ultra-rapide

```
Semaine 1: Modèles + ApiService + Providers
Semaine 2: Onboarding + Écrans (profile, jeux, home)
Semaine 3: 3 jeux (Memory, Word Search, Listening)
Semaine 4: Social (leaderboard, friends, share)
Semaine 5: Polish + optimisation
Semaine 6: Tests + beta release
```

---

## 💰 Budget MVP

```
Dev senior (6w × €6K):   €36,000
Dev junior (6w × €4K):   €24,000
QA (6w × €2.5K):         €15,000
Designer (6w × €2K):     €12,000
─────────────────────────────
Total:                   €87,000
```

---

## ⚠️ Top 5 risques

1. **Scope creep** → Sprint strict, MoSCoW
2. **Performance jeux** → Profiling dès semaine 1
3. **API bugs** → Integration tests exhaustifs
4. **Retention low** → UX testing continu
5. **Design inconsistency** → Figma components

---

## ✅ Must-have pour MVP

- [ ] 1 jeu (Quiz) jouable de bout en bout
- [ ] Défis journaliers
- [ ] Profil utilisateur + sélection langue
- [ ] Authentification + persistence tokens
- [ ] HomeScreen avec données réelles
- [ ] >80% test coverage
- [ ] Zero crashes en beta

---

## 🎯 Métriques succès

```
Code quality:      flutter analyze clean + >80% tests ✅
Performance:       <3s load + <1s interactions ✅
Stability:         0 crashes (100 users, 1w) ✅
Rating:            >4.0/5.0 stars ✅
Engagement:        >30% DAU ✅
Retention:         >70% day-7 ✅
```

---

## 🔗 Liens importants

- Flutter docs: https://flutter.dev/docs
- Provider package: https://pub.dev/packages/provider
- Django REST: https://www.django-rest-framework.org/
- Figma: https://www.figma.com/

---

## 📞 Contact & Support

```
Technical issues   → GitHub Issues
Design feedback    → Figma comments
Budget/timeline    → Project manager
Code review        → GitHub PRs
```

---

## 🎓 Ce qu'il faut savoir

### Flutter patterns
- ✅ Provider pattern pour state management
- ✅ Models avec fromJson/toJson
- ✅ Services pour API calls
- ✅ Screens avec Consumer/FutureBuilder

### Backend (déjà fait ✅)
- ✅ Django REST API avec authentification
- ✅ Token-based auth
- ✅ CORS configured
- ✅ Endpoints documentés

### Testing
- ✅ Unit tests pour modèles/providers
- ✅ Integration tests pour screens
- ✅ Widget tests pour composants
- ✅ Target: >80% coverage

---

## 🚀 Jour 1 : Checklist

```
□ Créer feature branch
□ Lire GUIDE_IMPLEMENTATION_IMMEDIATE.md
□ Copier code modèles (game, challenge, profile)
□ Créer game_models.dart
□ Créer challenge_models.dart
□ Créer profile_models.dart
□ Créer reward_models.dart
□ flutter pub get
□ flutter analyze ✅
□ Commit initial
```

---

## 🎮 Jour 2-3 : Checklist

```
□ Implémenter ApiService complet
□ Créer GameProvider
□ Créer ChallengeProvider
□ Créer ProfileProvider
□ Améliorer AuthProvider
□ Ajouter dependencies pubspec.yaml
□ Tests unitaires providers
□ flutter test ✅
□ Integration test basic
□ Commit
```

---

## 📱 Semaine 2 : Checklist

```
□ Créer OnboardingScreen (3 pages)
□ Créer LanguageSelectionScreen
□ Créer GamesListScreen
□ Créer QuizScreen (gameplay)
□ Créer GameResultScreen
□ Créer ProfileScreen
□ Intégrer providers dans screens
□ Error handling UI partout
□ Loading states (shimmer)
□ Navigation working
□ Internal testing
```

---

## 🏆 Commits conventions

```
feat: add game model and provider
fix: api service token handling
docs: update readme with setup
test: add game provider tests
chore: update dependencies
refactor: simplify quiz screen
```

---

## 🧪 Testing checklist

```
□ Unit tests:    lib/models, lib/providers, lib/services
□ Widget tests:  lib/widgets, lib/screens/auth
□ Integration:   Flow auth → home → game → result
□ Coverage:      >80% code coverage
□ Performance:   <3s startup time
□ Security:      Token storage, API calls
```

---

## 🎨 Design handoff

```
Designer → Figma mockups (27 screens)
           ↓
Dev → Extract specs (colors, sizes, fonts)
      ↓
Dev → Implement screens
      ↓
QA → Check pixel-perfect alignment
```

---

## 📈 Semaine par semaine

```
Week 1: 0 → 15% (modèles + API)
Week 2: 15% → 35% (onboarding + 1er jeu)
Week 3: 35% → 60% (3 jeux + profil)
Week 4: 60% → 80% (social + polish)
Week 5: 80% → 95% (optimisation)
Week 6: 95% → 100% (beta release)
```

---

## 🔥 Choses à ne PAS faire

```
❌ Modifier backend avant MVP (risque de breaking)
❌ Ajouter features qui ne sont pas dans MVP
❌ Négliger tests (dette technique)
❌ Hardcoder URLs/values (utiliser constants)
❌ Oublier gestion erreurs API
❌ Oublier de sauvegarder token après login
❌ Oublier edge cases (null, empty, error states)
```

---

## ✨ Quick wins (faire ces trucs en premier)

```
✅ Setup providers (30 min impact = énorme)
✅ Créer modèles complets (1h = fondation solide)
✅ Connecter API réelle (2h = données vivantes)
✅ Ajouter error handling UI (1h = app stable)
✅ Tests models (1h = confiance)
```

---

## 🎯 Success = ✅

```
✅ App lance sans crash
✅ Login/register fonctionne
✅ Jeux jouables de bout en bout
✅ Scores sauvegardés
✅ Profil se charge
✅ Défis intégrés
✅ Tests >80%
✅ Prêt beta testing

Then: Itération rapide basée metrics 📊
```

---

## 📊 High-level dependencies

```
main.dart
  ├─ MultiProvider
  │   ├─ AuthProvider
  │   ├─ GameProvider
  │   ├─ ChallengeProvider
  │   └─ ProfileProvider
  │
  └─ MyApp
      ├─ HomeScreen
      ├─ GameScreen
      ├─ ProfileScreen
      └─ LeaderboardScreen

Services:
  ├─ ApiService
  ├─ StorageService
  └─ NotificationService

Models:
  ├─ User
  ├─ Game
  ├─ Challenge
  ├─ Profile
  └─ Reward
```

---

## 🚨 Red flags / Blockers

```
🔴 API pas répondant       → Vérifier backend tourne
🔴 Token pas sauvegardé    → Vérifier secure storage
🔴 Écran blanc             → Vérifier provider wrapping
🔴 Images qui load pas     → Vérifier assets/pubspec.yaml
🔴 Crashes en tests        → Vérifier models fromJson
🔴 State pas updating      → Vérifier notifyListeners()
```

---

**Imprimez, affichez au mur, consultez quotidiennement ! 📌**

**Version** : 1.0  
**Mis à jour** : 22 nov 2025  
**Statut** : À utiliser en production  

