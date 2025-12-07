"""URL configuration for shop app."""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views
from .views import register, login, get_user_profile

router = DefaultRouter()
router.register(r'languages', views.LanguageViewSet)
router.register(r'games', views.GameViewSet)
router.register(r'challenges', views.ChallengeViewSet)
router.register(r'rewards', views.RewardViewSet)
router.register(r'profiles', views.UserProfileViewSet, basename='profile')

urlpatterns = [
    path('', include(router.urls)),
    
    path('auth/register/', views.register, name='register'),
    path('auth/login/', views.login, name='login'),
    path('auth/profile/', views.get_user_profile, name='profile'),
    
    # Avatar management
    path('avatars/', views.available_avatars, name='available-avatars'),
    
    # Game session management
    path('usergamesession/start/', views.start_user_game_session, name='user-game-session-start'),
    path('usergamesession/complete/<int:pk>/', views.complete_user_game_session, name='user-game-session-complete'),
    
    # Daily challenge endpoint
    path('daily-challenge/', views.daily_challenge, name='daily-challenge'),
    
    # Profile initialization
    path('initialize-profile/', views.initialize_profile, name='initialize-profile'),
        path('games/<int:pk>/questions/', views.game_questions, name='game-questions'),
]