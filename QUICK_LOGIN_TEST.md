# 📋 Guide Rapide - Tester la Connexion Corrigée

## 🎯 Objectif
Vérifier que la correction de l'erreur de connexion fonctionne correctement.

---

## ⚡ Étapes Rapides (5 minutes)

### Étape 1: Créer un utilisateur de test (1 min)

```powershell
cd C:\Users\user\Downloads\!!my_site\my_site
C:\Users\user\Downloads\!!my_site\ms_env\Scripts\python.exe manage.py shell -c "
from django.contrib.auth.models import User
user, _ = User.objects.get_or_create(username='testuser', defaults={'email': 'testuser@example.com', 'is_active': True})
user.set_password('TestPass123!')
user.save()
print('✅ Utilisateur testuser créé')
"
```

**Résultat attendu:**
```
✅ Utilisateur testuser créé
```

---

### Étape 2: Tester l'API directement (1 min)

```powershell
$response = Invoke-WebRequest -Uri "http://localhost:8000/api/auth/login/" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"username":"testuser","password":"TestPass123!"}' `
  -UseBasicParsing

Write-Host "Status: $($response.StatusCode)"
$response.Content | ConvertFrom-Json | Select-Object -Property token, user
```

**Résultat attendu:**
```
Status: 200
token : c3afe5784448c0ab533907dd7b257aa6b3325839
user  : @{id=10; username=testuser; email=testuser@example.com}
```

---

### Étape 3: Lancer l'app Flutter (2 min)

```powershell
cd C:\Users\user\Downloads\!!my_site\frontend\linguaplay_app
flutter run
```

---

### Étape 4: Se connecter dans l'app (1 min)

1. **Écran de login s'affiche**
2. **Champ "Nom d'utilisateur"** (avant c'était "Email")
3. **Entrez:**
   - Nom d'utilisateur: `testuser`
   - Mot de passe: `TestPass123!`
4. **Cliquez "Se connecter"**

---

## ✅ Vérification de Succès

### Si ça marche ✅
- L'app se connecte
- Vous arrivez sur l'écran d'accueil
- Pas d'erreur affichée

### Si ça ne marche pas ❌
- Vérifiez que `testuser` a été créé (étape 1)
- Vérifiez que l'API répond (étape 2)
- Consultez les logs Flutter: `flutter logs`

---

## 📊 Résumé des Changements

| Avant | Après |
|-------|-------|
| ❌ Demandait email | ✅ Demande username |
| ❌ Backend rigide | ✅ Backend flexible (username OR email) |
| ❌ Erreurs génériques | ✅ Messages clairs |

---

## 🧪 Tests Automatiques

Les tests passent tous:
```powershell
# Backend
cd C:\Users\user\Downloads\!!my_site\my_site
C:\Users\user\Downloads\!!my_site\ms_env\Scripts\python.exe manage.py test shop.tests
# Result: OK - 4 tests

# Frontend
cd C:\Users\user\Downloads\!!my_site\frontend\linguaplay_app
flutter test
# Result: OK - 4 tests
```

---

## 📖 Documentation Complète

Pour plus de détails, consultez:
- **LOGIN_TROUBLESHOOTING_GUIDE.md** - Dépannage complet
- **CONNECTION_FIX_SUMMARY.md** - Résumé technique

---

## 🚀 Prêt à Tester?

Commencez par l'étape 1 ci-dessus!

**Durée estimée:** 5-10 minutes  
**Difficulté:** Facile ✅

---

*Dernière mise à jour: 22 Novembre 2025*
