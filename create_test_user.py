import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'my_site.settings')
django.setup()

from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token

# Créer un utilisateur de test s'il n'existe pas
user, created = User.objects.get_or_create(
    username='testuser',
    defaults={
        'email': 'testuser@example.com',
        'is_active': True
    }
)

# Définir le mot de passe
if created:
    user.set_password('TestPass123!')
    user.save()
    print(f"✅ Utilisateur créé: {user.username}")
else:
    # Mettre à jour le mot de passe même si l'utilisateur existe
    user.set_password('TestPass123!')
    user.save()
    print(f"✅ Utilisateur existant mis à jour: {user.username}")

# Créer ou récupérer le token
token, created = Token.objects.get_or_create(user=user)
print(f"✅ Token créé/récupéré: {token.key[:20]}...")
print(f"📧 Email: {user.email}")
print(f"🔒 Mot de passe: TestPass123!")
print("\n✅ Prêt à se connecter!")
