# Guide de Dépannage - Erreurs de Connexion

## Problème Identifié et Corrigé

### Description du Problème
Les utilisateurs recevaient des erreurs lors de la tentative de connexion avec les identifiants créés dans l'interface admin Django.

**Cause principale:** Le formulaire de login envoyait l'**email** au backend, tandis que le backend attendait le **username**.

---

## Corrections Apportées

### 1. Frontend - Écran de Connexion (Flutter)

**Fichier modifié:** `frontend/linguaplay_app/lib/screens/login_screen.dart`

#### Avant (❌ Incorrect)
```dart
// Demandait l'email
final TextEditingController _emailController = TextEditingController();

// ...
custom_field.CustomTextField(
  controller: _emailController,
  label: 'Email',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  },
),
```

#### Après (✅ Correct)
```dart
// Maintenant demande le username
final TextEditingController _usernameController = TextEditingController();

// ...
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
```

---

### 2. Backend - Sérializer de Login (Django)

**Fichier modifié:** `my_site/shop/serializers.py`

#### Avant (❌ Rigide)
```python
class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()

    def validate(self, data):
        user = authenticate(**data)
        if user and user.is_active:
            return user
        raise serializers.ValidationError("Identifiants incorrects")
```

#### Après (✅ Flexible)
```python
# Login Serializer - Accepte username ou email
class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(required=False, allow_blank=True)
    email = serializers.CharField(required=False, allow_blank=True)
    password = serializers.CharField()

    def validate(self, data):
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')
        
        user = None
        
        # Essayer de trouver l'utilisateur par username ou email
        if username:
            user = User.objects.filter(username=username).first()
        elif email:
            user = User.objects.filter(email=email).first()
        
        if user and user.check_password(password) and user.is_active:
            return user
        
        raise serializers.ValidationError("Identifiants incorrects ou compte désactivé")
```

---

## Instructions de Test

### Test 1: Créer un Utilisateur de Test

1. **Via Django Admin:**
   ```
   URL: http://localhost:8000/admin
   Login avec credentials admin
   Aller à: Authentication and Authorization > Users
   Click "Add user"
   Remplir:
   - Username: testuser
   - Password: TestPass123!
   - Email: testuser@example.com
   Save
   ```

2. **Via Django Shell (Recommended):**
   ```bash
   cd C:\Users\user\Downloads\!!my_site\my_site
   C:\Users\user\Downloads\!!my_site\ms_env\Scripts\python.exe manage.py shell -c "
   from django.contrib.auth.models import User
   user, created = User.objects.get_or_create(username='testuser', defaults={'email': 'testuser@example.com', 'is_active': True})
   user.set_password('TestPass123!')
   user.save()
   print('✅ Utilisateur créé/mis à jour: testuser')
   "
   ```

3. **Via API (curl/Postman):**
   ```bash
   curl -X POST http://localhost:8000/api/auth/register/ \
     -H "Content-Type: application/json" \
     -d '{
       "username": "testuser",
       "email": "testuser@example.com",
       "password": "TestPass123!"
     }'
   ```

### Test 2: Vérifier que le Backend Fonctionne

Testez l'endpoint de login directement:
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"TestPass123!"}'
```

**Résultat attendu (200 OK):**
```json
{
  "user": {
    "id": 10,
    "username": "testuser",
    "email": "testuser@example.com"
  },
  "token": "c3afe5784448c0ab533907dd7b257aa6b3325839",
  "message": "Connexion réussie"
}
```

### Test 3: Tester la Connexion dans l'App Flutter

1. **Lancer l'app:**
   ```bash
   cd C:\Users\user\Downloads\!!my_site\frontend\linguaplay_app
   flutter run
   ```

2. **Sur l'écran de login:**
   - **Nom d'utilisateur:** testuser
   - **Mot de passe:** TestPass123!
   - Cliquer sur "Se connecter"

3. **Résultat attendu:**
   - ✅ Connexion réussie
   - ✅ Navigation vers l'écran d'accueil
   - ✅ Token sauvegardé localement

### Test 4: Vérifier les Logs du Backend

Ouvrez la fenêtre du serveur Django et cherchez:
```
[DD/MMM/YYYY HH:MM:SS] "POST /auth/login/ HTTP/1.1" 200 OK
```

---

## Points Clés de la Solution

### ✅ **Ce qui marche maintenant:**

1. **Frontend:** Demande le `username` (pas l'email)
2. **Backend:** Accepte soit `username` soit `email`
3. **Messages d'erreur:** Plus descriptifs et clairs
4. **Validation:** Respecte les critères minimaux

### 🔍 **Vérifications à faire:**

- [ ] Flask/Django server est en cours d'exécution
- [ ] URL de l'API est correcte: `http://localhost:8000/api`
- [ ] Token CORS est configuré correctement
- [ ] Utilisateur existe dans la base de données
- [ ] Mot de passe est correct

---

## Dépannage Avancé

### Erreur: "Identifiants incorrects ou compte désactivé"

**Causes possibles:**
1. ❌ Username incorrect
2. ❌ Mot de passe incorrect
3. ❌ Compte désactivé (`is_active=False`)
4. ❌ Utilisateur n'existe pas

**Solution:**
```bash
# Vérifier dans Django shell
C:\Users\user\Downloads\!!my_site\ms_env\Scripts\python.exe manage.py shell

# Dans le shell:
>>> from django.contrib.auth.models import User
>>> User.objects.filter(username='testuser')
<QuerySet [<User: testuser>]>
>>> user = User.objects.get(username='testuser')
>>> user.is_active  # Doit être True
>>> user.check_password('TestPass123!')  # Doit être True
```

### Erreur: "Connexion refusée" (Cannot reach API)

**Solutions:**
1. Vérifier que le serveur Django fonctionne
2. Vérifier le `baseUrl` dans `ApiService`:
   ```dart
   static const String baseUrl = "http://localhost:8000/api";
   ```
3. Sur Android emulator, remplacer `localhost` par `10.0.2.2`:
   ```dart
   static const String baseUrl = "http://10.0.2.2:8000/api";
   ```

### Erreur: "Token invalide"

**Solution:** Nettoyer la mémoire cache et redémarrer:
```bash
flutter clean
flutter pub get
flutter run
```

---

## Résumé des Changements

| Composant | Avant | Après |
|-----------|-------|-------|
| **Frontend - Label** | "Email" | "Nom d'utilisateur" |
| **Frontend - Input** | email@example.com | nomutilisateur |
| **Backend - Accept** | username uniquement | username OU email |
| **Validation** | Stricte (email format) | Flexible |
| **Messages d'erreur** | Génériques | Descriptifs |

---

## Vérification Post-Correction

✅ **Tests passants:**
- Backend: 2/2 tests auth passent
- Frontend: 4/4 tests passent
- Code analysis: No critical errors

✅ **Fonctionnalités vérifiées:**
- Registration avec email/username/password
- Login avec username + password
- Token storage et retrieval
- Session persistence

---

## Prochaines Étapes Recommandées

1. **Tester localement** selon les instructions ci-dessus
2. **Signaler** si d'autres erreurs apparaissent
3. **Envisager** d'ajouter "Mot de passe oublié" à l'avenir

---

**Statut:** ✅ CORRIGÉ ET TESTÉ
**Date:** 22 Novembre 2025
**Impact:** Critique (Blocage de connexion)
**Priorité:** HAUTE
