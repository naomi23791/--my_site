from rest_framework import viewsets, filters, status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.templatetags.static import static
from django.conf import settings
from pathlib import Path
from .models import Challenge, UserChallengeProgress, Language, Game, UserProfile, Reward, UserGameSession
from .serializers import (
    LanguageSerializer, GameSerializer, ChallengeSerializer,
    UserProfileSerializer, RewardSerializer, UserChallengeProgressSerializer,
    UserGameSessionSerializer
)
from rest_framework import generics, permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from django.contrib.auth.models import User
from .serializers import UserSerializer, RegisterSerializer, LoginSerializer
from rest_framework.authtoken.models import Token



# Complete ViewSets for CRUD operations

class LanguageViewSet(viewsets.ModelViewSet):
    """Full CRUD ViewSet for languages with filters and search."""
    queryset = Language.objects.all()
    serializer_class = LanguageSerializer
    permission_classes = [AllowAny]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'code']
    filterset_fields = ['code']
    ordering_fields = ['name', 'id']
    ordering = ['name']


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
        # Insert logic to start the game if any
        return Response({
            "message": f"Game {game.title} started",
            "game_id": game.id
        })
@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            "user": UserSerializer(user).data,
            "token": token.key,
            "message": "Utilisateur créé avec succès"
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.validated_data
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            "user": UserSerializer(user).data,
            "token": token.key,
            "message": "Connexion réussie"
        })
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def get_user_profile(request):
    serializer = UserSerializer(request.user)
    return Response(serializer.data)   


class ChallengeViewSet(viewsets.ModelViewSet):
    """Full CRUD ViewSet for challenges."""
    queryset = Challenge.objects.all()
    serializer_class = ChallengeSerializer
    permission_classes = [AllowAny]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['title', 'description']
    filterset_fields = ['is_daily', 'language']


@api_view(['GET'])
@permission_classes([AllowAny])
def game_questions(request, pk):
    """Return a small set of sample quiz questions for a given game id.
    This is a lightweight endpoint to support the frontend quiz prototype.
    """
    # In a real implementation, questions would come from the database.
    sample_questions = [
        {
            'id': 1,
            'game_id': int(pk),
            'question': 'Comment dit-on "apple" en français ?',
            'options': ['pomme', 'banane', 'orange', 'poire'],
            'correct_answer': 'pomme',
            'explanation': '"Apple" se traduit par "pomme".',
            'order': 1,
        },
        {
            'id': 2,
            'game_id': int(pk),
            'question': 'Quelle est la traduction de "hello" ?',
            'options': ['bonjour', 'au revoir', 'salut', 'merci'],
            'correct_answer': 'bonjour',
            'explanation': '"Hello" se traduit généralement par "bonjour".',
            'order': 2,
        },
        {
            'id': 3,
            'game_id': int(pk),
            'question': 'Complétez: "Je ____ une pomme."',
            'options': ['mange', 'manges', 'mangent', 'manger'],
            'correct_answer': 'mange',
            'explanation': 'La forme correcte est "Je mange".',
            'order': 3,
        },
    ]

    return Response(sample_questions)
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


class RewardViewSet(viewsets.ModelViewSet):
    """Full CRUD ViewSet for rewards."""
    queryset = Reward.objects.all()
    serializer_class = RewardSerializer
    permission_classes = [AllowAny]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'description']
    filterset_fields = ['points_required']
    ordering_fields = ['name', 'points_required']
    ordering = ['points_required']

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def available_rewards(self, request):
        """Rewards available to the user based on their points."""
        user_profile = get_object_or_404(UserProfile, user=request.user)
        available_rewards = Reward.objects.filter(
            points_required__lte=user_profile.total_points
        )
        serializer = self.get_serializer(available_rewards, many=True)
        return Response(serializer.data)


class UserProfileViewSet(viewsets.ModelViewSet):
    """ViewSet for user profiles, authenticated access only."""
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """Users can only see their own profile, staff can see all."""
        if self.request.user.is_staff:
            return UserProfile.objects.all()
        return UserProfile.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        """Automatically assign the current user when creating a profile."""
        if UserProfile.objects.filter(user=self.request.user).exists():
            from rest_framework.exceptions import ValidationError
            raise ValidationError({"detail": "You already have a profile."})
        serializer.save(user=self.request.user)

    def get_serializer_context(self):
        """Add request to serializer context."""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    @action(detail=False, methods=['get', 'put', 'patch'])
    def my_profile(self, request):
        """
        Handle the current user's profile.
        GET: Retrieve profile (creates one if it doesn't exist)
        PUT/PATCH: Update profile
        """
        profile, created = UserProfile.objects.get_or_create(user=request.user)

        if request.method == 'GET':
            serializer = self.get_serializer(profile)
            return Response(serializer.data)

        elif request.method in ['PUT', 'PATCH']:
            serializer = self.get_serializer(
                profile,
                data=request.data,
                partial=request.method == 'PATCH'
            )
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def leaderboard(self, request):
        """Leaderboard of users by total points."""
        leaders = UserProfile.objects.all().order_by('-total_points')[:10]
        serializer = self.get_serializer(leaders, many=True)
        return Response(serializer.data)


@api_view(['GET'])
@permission_classes([AllowAny])
def available_avatars(request):
    """List available built-in avatar images as absolute URLs (static files)."""
    avatar_dir: Path | None = None
    if hasattr(settings, 'STATICFILES_DIRS') and settings.STATICFILES_DIRS:
        # We assume the first entry is the avatars directory we added in settings
        candidate = Path(settings.STATICFILES_DIRS[0])
        if candidate.exists() and candidate.is_dir():
            avatar_dir = candidate
    if not avatar_dir:
        return Response({"results": []})

    files = []
    for p in avatar_dir.iterdir():
        if p.is_file() and p.suffix.lower() in {'.png', '.jpg', '.jpeg', '.webp', '.gif'}:
            files.append({
                "filename": p.name,
                "url": request.build_absolute_uri(static(p.name))
            })
    return Response({"results": files})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def start_user_game_session(request):
    """Create a user game session when user starts a game."""
    user = request.user
    game_id = request.data.get('game_id')
    if not game_id:
        return Response({'detail': 'game_id is required.'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        game = Game.objects.get(id=game_id)
    except Game.DoesNotExist:
        return Response({'detail': 'Game not found.'}, status=status.HTTP_404_NOT_FOUND)

    # Get or create user profile
    user_profile, created = UserProfile.objects.get_or_create(user=user)

    session = UserGameSession.objects.create(user=user, game=game)
    serializer = UserGameSessionSerializer(session)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def complete_user_game_session(request, pk):
    """Mark a user game session as completed, with optional score."""
    try:
        session = UserGameSession.objects.get(pk=pk, user=request.user)
    except UserGameSession.DoesNotExist:
        return Response({'detail': 'Session not found.'}, status=status.HTTP_404_NOT_FOUND)

    session.completed_at = timezone.now()
    score = request.data.get('score')
    if score is not None:
        try:
            session.score = float(score)
        except ValueError:
            return Response({'detail': 'Score must be a number.'}, status=status.HTTP_400_BAD_REQUEST)
    session.save()

    # Update user profile points if score is provided
    if score is not None:
        user_profile, created = UserProfile.objects.get_or_create(user=request.user)
        user_profile.total_points += int(score)
        user_profile.save()

    serializer = UserGameSessionSerializer(session)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def daily_challenge(request):
    """Return the current daily challenge for the authenticated user."""
    today = timezone.now().date()

    # Get today's daily challenge
    daily_challenge = Challenge.objects.filter(
        is_daily=True,
        start_date__lte=timezone.now(),
        end_date__gte=timezone.now()
    ).first()

    if not daily_challenge:
        return Response(
            {"message": "No daily challenge available today."},
            status=status.HTTP_404_NOT_FOUND
        )

    # Get or create user profile
    user_profile, created = UserProfile.objects.get_or_create(user=request.user)

    # Check if the user has already completed this challenge
    user_progress, created = UserChallengeProgress.objects.get_or_create(
        user=request.user,
        challenge=daily_challenge
    )

    data = {
        "challenge": {
            "id": daily_challenge.id,
            "title": daily_challenge.title,
            "description": daily_challenge.description,
            "points_reward": daily_challenge.points_reward,
            "is_completed": user_progress.is_completed,
        },
        "user_profile": {
            "total_points": user_profile.total_points,
            "current_streak": user_profile.current_streak,
        }
    }

    return Response(data)


# Additional helper view for profile initialization
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def initialize_profile(request):
    """Initialize a user profile with default values."""
    profile, created = UserProfile.objects.get_or_create(
        user=request.user,
        defaults={
            'total_points': 0,
            'current_streak': 0,
        }
    )
    
    if not created:
        return Response(
            {"detail": "Profile already exists."},
            status=status.HTTP_400_BAD_REQUEST
        )

    serializer = UserProfileSerializer(profile, context={'request': request})
    return Response(serializer.data, status=status.HTTP_201_CREATED)
