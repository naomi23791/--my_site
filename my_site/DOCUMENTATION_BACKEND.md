# Documentation Backend - Application d'Apprentissage de Langues

## 1. Architecture Générale

Le backend de l'application est construit avec **Django 5.2.7** et **Django REST Framework (DRF)**, fournissant une API REST complète pour une application web d'apprentissage de langues. L'architecture suit le pattern **MVC (Model-View-Controller)** adapté à Django : **Models (modèles de données)**, **Views (logique métier et API)**, et **Serializers (transformation des données)**.

### Configuration Django REST Framework

```python
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticatedOrReadOnly',
    ],
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}
```

Cette configuration permet :
- **Authentification par token** pour les clients API
- **Permissions** : lecture libre, écriture authentifiée
- **Filtres avancés** : recherche, tri, filtrage par champs
- **Pagination automatique** : 20 éléments par page

---

## 2. Modèles de Données (Models)

Les modèles définissent la structure de la base de données et les relations entre entités. Tous les modèles utilisent des **index de performance** (`db_index=True`) et des **contraintes d'unicité** pour garantir l'intégrité des données.

### 2.1 Modèle Language

Représente les langues disponibles dans l'application.

```python
class Language(models.Model):
    """Model for languages available in the app."""
    name = models.CharField(max_length=100, verbose_name="Language Name")
    code = models.CharField(max_length=10, unique=True, verbose_name="ISO Code")
    flag_icon = models.CharField(max_length=50, blank=True, verbose_name="Flag Icon")
```

**Relations** : Utilisé par `Game` et `Challenge` via ForeignKey, et par `UserProfile` via ManyToMany.

### 2.2 Modèle Game

Représente les jeux éducatifs (quiz, memory, mots cachés). Supporte les **jeux externes** via les champs `is_external` et `external_url`.

```python
class Game(models.Model):
    class Difficulty(models.IntegerChoices):
        EASY = 1, "Easy"
        MEDIUM = 2, "Medium"
        DIFFICULT = 3, "Difficult"
        EXPERT = 4, "Expert"
        LEGENDARY = 5, "Legendary"

    title = models.CharField(max_length=200, verbose_name="Game Title")
    game_type = models.CharField(max_length=20, choices=GAMETYPE_CHOICES)
    description = models.TextField(blank=True)
    language = models.ForeignKey(Language, on_delete=models.CASCADE, db_index=True)
    difficulty = models.IntegerField(choices=Difficulty.choices, default=Difficulty.EASY)
    is_external = models.BooleanField(default=False, verbose_name="Is External Game")
    external_url = models.URLField(blank=True, null=True, verbose_name="External Game URL")
```

**Fonctionnalités** : 
- Support des jeux hébergés externes (LearningApps, etc.)
- Système de difficulté avec 5 niveaux
- 4 types de jeux : Quiz, Memory Game, Word Search, Listening Comprehension

### 2.3 Modèle UserProfile

Extension du modèle User de Django, stocke les informations spécifiques à l'apprentissage (points, série, langues apprises, avatar).

```python
class UserProfile(models.Model):
    """Extension of Django's User model."""
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    languages_learning = models.ManyToManyField(Language, verbose_name="Languages being Learned")
    current_streak = models.IntegerField(default=0, verbose_name="Current Learning Streak")
    total_points = models.IntegerField(default=0, verbose_name="Total Points")
    avatar = models.ImageField(upload_to='avatars/', blank=True, verbose_name="Avatar")
```

**Caractéristiques** : Relation OneToOne avec User (un profil par utilisateur), ManyToMany avec Language (plusieurs langues par utilisateur).

### 2.4 Modèle Challenge et UserChallengeProgress

`Challenge` représente les défis quotidiens ou spéciaux. `UserChallengeProgress` suit la progression de chaque utilisateur sur chaque défi.

```python
class Challenge(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField()
    language = models.ForeignKey(Language, on_delete=models.CASCADE, db_index=True)
    points_reward = models.IntegerField(default=10)
    is_daily = models.BooleanField(default=False)
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    
    def clean(self):
        if self.end_date < self.start_date:
            raise ValidationError("End date should be after start date.")

class UserChallengeProgress(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_index=True)
    challenge = models.ForeignKey(Challenge, on_delete=models.CASCADE, db_index=True)
    is_completed = models.BooleanField(default=False)
    completion_date = models.DateTimeField(blank=True, null=True)
    
    class Meta:
        unique_together = ('user', 'challenge')
```

**Sécurité** : La contrainte `unique_together` empêche un utilisateur d'avoir plusieurs progressions pour le même défi.

### 2.5 Modèle UserGameSession

Enregistre les sessions de jeu des utilisateurs (début, fin, score), que le jeu soit interne ou externe.

```python
class UserGameSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    game = models.ForeignKey(Game, on_delete=models.CASCADE)
    started_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(blank=True, null=True)
    score = models.FloatField(blank=True, null=True)
```

---

## 3. Serializers (Transformation des Données)

Les serializers convertissent les objets Python (modèles) en JSON pour l'API et valident les données entrantes. Ils gèrent également les **relations ManyToMany** et les **champs calculés**.

### 3.1 UserProfileSerializer

Gère la création et la mise à jour des profils utilisateurs avec gestion des langues (ManyToMany).

```python
class UserProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.CharField(source='user.email', read_only=True)
    languages_learning_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Language.objects.all(),
        source='languages_learning',
        required=False
    )

    def create(self, validated_data):
        """Create a user profile, associating it with the authenticated user."""
        request = self.context.get('request')
        user = request.user
        languages = validated_data.pop('languages_learning', [])
        
        if UserProfile.objects.filter(user=user).exists():
            raise serializers.ValidationError({"detail": "A profile already exists."})
        
        profile = UserProfile.objects.create(user=user, **validated_data)
        if languages:
            profile.languages_learning.set(languages)
        return profile

    def update(self, instance, validated_data):
        """Update the user profile."""
        languages = validated_data.pop('languages_learning', None)
        validated_data.pop('user', None)  # Prevent user change
        
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        if languages is not None:
            instance.languages_learning.set(languages)
        return instance
```

**Points clés** : 
- Récupération automatique de l'utilisateur authentifié via `context['request']`
- Gestion explicite des ManyToMany (languages_learning)
- Validation pour éviter les doublons de profil

---

## 4. Vues et API Endpoints (Views)

Les **ViewSets** de DRF fournissent automatiquement les opérations CRUD (Create, Read, Update, Delete) et des **actions personnalisées** via le décorateur `@action`.

### 4.1 GameViewSet

Gère les jeux avec filtres, recherche et action personnalisée pour démarrer un jeu.

```python
class GameViewSet(viewsets.ModelViewSet):
    """Full CRUD ViewSet for games."""
    queryset = Game.objects.all()
    serializer_class = GameSerializer
    permission_classes = [AllowAny]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['title', 'description']
    filterset_fields = ['difficulty', 'language']
    ordering_fields = ['title', 'difficulty']
    ordering = ['title']

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def start_game(self, request, pk=None):
        """Start a game for the authenticated user."""
        game = self.get_object()
        return Response({
            "message": f"Game {game.title} started",
            "game_id": game.id
        })
```

**Endpoints générés automatiquement** :
- `GET /api/games/` : Liste tous les jeux (avec filtres, recherche, tri)
- `GET /api/games/{id}/` : Détails d'un jeu
- `POST /api/games/` : Créer un jeu (admin)
- `PUT/PATCH /api/games/{id}/` : Modifier un jeu
- `DELETE /api/games/{id}/` : Supprimer un jeu
- `POST /api/games/{id}/start_game/` : Action personnalisée pour démarrer

### 4.2 ChallengeViewSet avec Actions Personnalisées

Fournit des actions spéciales pour les défis actifs et la complétion.

```python
class ChallengeViewSet(viewsets.ModelViewSet):
    queryset = Challenge.objects.all()
    serializer_class = ChallengeSerializer
    permission_classes = [AllowAny]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['title', 'description']
    filterset_fields = ['is_daily', 'language']
    ordering_fields = ['title', 'points_reward', 'start_date']
    ordering = ['-start_date']

    @action(detail=False, methods=['get'])
    def active_challenges(self, request):
        """Return only active challenges."""
        active_challenges = Challenge.objects.filter(
            start_date__lte=timezone.now(),
            end_date__gte=timezone.now()
        )
        serializer = self.get_serializer(active_challenges, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def complete_challenge(self, request, pk=None):
        """Mark a challenge as completed by the authenticated user."""
        challenge = self.get_object()
        user_progress, _ = UserChallengeProgress.objects.get_or_create(
            user=request.user,
            challenge=challenge
        )
        user_progress.is_completed = True
        user_progress.completion_date = timezone.now()
        user_progress.save()
        return Response({
            "message": f"Challenge {challenge.title} completed!",
            "points_earned": challenge.points_reward
        })
```

**Endpoints additionnels** :
- `GET /api/challenges/active_challenges/` : Défis actifs uniquement
- `POST /api/challenges/{id}/complete_challenge/` : Marquer un défi comme complété

### 4.3 UserProfileViewSet avec Gestion Automatique

Gère les profils avec création automatique si nécessaire et classement.

```python
class UserProfileViewSet(viewsets.ModelViewSet):
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """Users can only see their own profile, staff can see all."""
        if self.request.user.is_staff:
            return UserProfile.objects.all()
        return UserProfile.objects.filter(user=self.request.user)

    @action(detail=False, methods=['get', 'put', 'patch'])
    def my_profile(self, request):
        """Handle the current user's profile. Creates one if it doesn't exist."""
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        
        if request.method == 'GET':
            serializer = self.get_serializer(profile)
            return Response(serializer.data)
        
        elif request.method in ['PUT', 'PATCH']:
            serializer = self.get_serializer(profile, data=request.data, partial=request.method == 'PATCH')
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def leaderboard(self, request):
        """Leaderboard of users by total points."""
        leaders = UserProfile.objects.all().order_by('-total_points')[:10]
        serializer = self.get_serializer(leaders, many=True)
        return Response(serializer.data)
```

**Endpoints clés** :
- `GET /api/profiles/my_profile/` : Mon profil (création auto si absent)
- `PUT/PATCH /api/profiles/my_profile/` : Mettre à jour mon profil
- `GET /api/profiles/leaderboard/` : Top 10 des utilisateurs par points

### 4.4 Endpoints Fonctionnels Personnalisés

Endpoints spécialisés pour les sessions de jeu et défis quotidiens.

```python
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def start_user_game_session(request):
    """Create a user game session when user starts a game."""
    game_id = request.data.get('game_id')
    game = Game.objects.get(id=game_id)
    user_profile, created = UserProfile.objects.get_or_create(user=request.user)
    session = UserGameSession.objects.create(user=request.user, game=game)
    serializer = UserGameSessionSerializer(session)
    return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def complete_user_game_session(request, pk):
    """Mark a user game session as completed, with optional score."""
    session = UserGameSession.objects.get(pk=pk, user=request.user)
    session.completed_at = timezone.now()
    score = request.data.get('score')
    if score is not None:
        session.score = float(score)
        user_profile, created = UserProfile.objects.get_or_create(user=request.user)
        user_profile.total_points += int(score)
        user_profile.save()
    session.save()
    return Response(UserGameSessionSerializer(session).data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def daily_challenge(request):
    """Return the current daily challenge for the authenticated user."""
    daily_challenge = Challenge.objects.filter(
        is_daily=True,
        start_date__lte=timezone.now(),
        end_date__gte=timezone.now()
    ).first()
    
    user_profile, created = UserProfile.objects.get_or_create(user=request.user)
    user_progress, created = UserChallengeProgress.objects.get_or_create(
        user=request.user,
        challenge=daily_challenge
    )
    
    return Response({
        "challenge": {
            "id": daily_challenge.id,
            "title": daily_challenge.title,
            "points_reward": daily_challenge.points_reward,
            "is_completed": user_progress.is_completed,
        },
        "user_profile": {
            "total_points": user_profile.total_points,
            "current_streak": user_profile.current_streak,
        }
    })
```

---

## 5. Configuration des URLs

Le système de routage utilise le **DefaultRouter** de DRF pour générer automatiquement les URLs REST, plus des routes personnalisées pour les endpoints fonctionnels.

```python
# shop/urls.py
router = DefaultRouter()
router.register(r'languages', views.LanguageViewSet)
router.register(r'games', views.GameViewSet)
router.register(r'challenges', views.ChallengeViewSet)
router.register(r'rewards', views.RewardViewSet)
router.register(r'profiles', views.UserProfileViewSet, basename='profile')

urlpatterns = [
    path('', include(router.urls)),
    path('avatars/', views.available_avatars, name='available-avatars'),
    path('usergamesession/start/', views.start_user_game_session, name='user-game-session-start'),
    path('usergamesession/complete/<int:pk>/', views.complete_user_game_session, name='user-game-session-complete'),
    path('daily-challenge/', views.daily_challenge, name='daily-challenge'),
    path('initialize-profile/', views.initialize_profile, name='initialize-profile'),
]
```

**Structure des URLs générées** :
- `/api/languages/` - CRUD pour les langues
- `/api/games/` - CRUD pour les jeux
- `/api/challenges/` - CRUD pour les défis
- `/api/profiles/` - CRUD pour les profils
- `/api/rewards/` - CRUD pour les récompenses

---

## 6. Fonctionnalités Avancées

### 6.1 Système de Jeux Externes

Le champ `is_external` dans le modèle `Game` permet d'intégrer des jeux hébergés externes (LearningApps, etc.). Le frontend peut détecter ces jeux et les afficher via iframe ou lien direct.

```python
# Dans Game model
is_external = models.BooleanField(default=False, verbose_name="Is External Game")
external_url = models.URLField(blank=True, null=True, verbose_name="External Game URL")
```

### 6.2 Gestion des Fichiers Médias

Les avatars utilisateurs et les fichiers statiques sont gérés via Django.

```python
# settings.py
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'
STATICFILES_DIRS = [
    BASE_DIR.parent / 'avatars',
]
```

### 6.3 Sécurité et Permissions

- **Token Authentication** : Authentification par token pour les clients API
- **Permission Classes** : Contrôle d'accès par endpoint (AllowAny, IsAuthenticated)
- **Queryset Filtering** : Les utilisateurs ne voient que leurs propres profils (sauf staff)

---

## Conclusion

Le backend Django REST Framework fournit une API REST complète et sécurisée pour une application d'apprentissage de langues. L'architecture modulaire permet une maintenance facile et une évolution future. Les ViewSets automatisent les opérations CRUD standard, tandis que les actions personnalisées et les endpoints fonctionnels gèrent la logique métier spécifique à l'application.

**Points forts** :
- API REST standardisée et documentée automatiquement
- Support des jeux internes et externes
- Système de progression et de récompenses intégré
- Authentification et permissions robustes
- Performance optimisée (index, pagination, filtres)

