"""URL configuration for shop app."""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'languages', views.LanguageViewSet)
router.register(r'games', views.GameViewSet)
router.register(r'challenges', views.ChallengeViewSet)
router.register(r'rewards', views.RewardViewSet)
router.register(r'profiles', views.UserProfileViewSet, basename='profile')

urlpatterns = [
    path('', include(router.urls)),
    
    # Avatar management
    path('avatars/', views.available_avatars, name='available-avatars'),
    
    # Game session management
    path('usergamesession/start/', views.start_user_game_session, name='user-game-session-start'),
    path('usergamesession/complete/<int:pk>/', views.complete_user_game_session, name='user-game-session-complete'),
    
    # Daily challenge endpoint
    path('daily-challenge/', views.daily_challenge, name='daily-challenge'),
    
    # Profile initialization
    path('initialize-profile/', views.initialize_profile, name='initialize-profile'),
]