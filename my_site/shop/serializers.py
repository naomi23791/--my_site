from rest_framework import serializers
from .models import Language, Game, UserProfile, Challenge, Reward, UserChallengeProgress, UserGameSession

class LanguageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Language
        fields = '__all__'

class GameSerializer(serializers.ModelSerializer):
    class Meta:
        model = Game
        fields = '__all__'  # is_external, external_url now included

# class UserProfileSerializer(serializers.ModelSerializer):
#     username = serializers.CharField(source='user.username', read_only=True)
#     email = serializers.CharField(source='user.email', read_only=True)
#     class Meta:
#         model = UserProfile
#         fields = [
#             'id', 'user', 'username', 'email', 'total_points', 'current_streak', 'avatar', 'languages_learning',
#         ]
#         read_only_fields = ['user']

class UserProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.CharField(source='user.email', read_only=True)
    languages_learning_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Language.objects.all(),
        source='languages_learning',
        required=False
    )

    class Meta:
        model = UserProfile
        fields = [
            'id',
            'user',
            'username',
            'email',
            'total_points',
            'current_streak',
            'languages_learning',
            'languages_learning_ids',
            'avatar',
        ]
        read_only_fields = ['user']

    def create(self, validated_data):
        """Create a user profile, associating it with the authenticated user."""
        # Get user from context
        request = self.context.get('request')
        if not request or not hasattr(request, 'user'):
            raise serializers.ValidationError("User must be authenticated.")
        
        user = request.user
        languages = validated_data.pop('languages_learning', [])
        
        # Check if profile already exists
        if UserProfile.objects.filter(user=user).exists():
            raise serializers.ValidationError({"detail": "A profile already exists for this user."})

        # Create profile
        profile = UserProfile.objects.create(user=user, **validated_data)
        
        # Add languages
        if languages:
            profile.languages_learning.set(languages)
        
        return profile

    def update(self, instance, validated_data):
        """Update the user profile."""
        languages = validated_data.pop('languages_learning', None)
        
        # Remove user from validated_data if present (shouldn't be changed)
        validated_data.pop('user', None)
        
        # Update fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        # Update languages if provided
        if languages is not None:
            instance.languages_learning.set(languages)
        
        return instance

class ChallengeSerializer(serializers.ModelSerializer):
    language_name = serializers.CharField(source='language.name', read_only=True)
    class Meta:
        model = Challenge
        fields = [
            'id', 'title', 'description', 'language', 'language_name', 'points_reward', 'is_daily', 'start_date', 'end_date'
        ]

class RewardSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reward
        fields = '__all__'

class UserChallengeProgressSerializer(serializers.ModelSerializer):
    challenge_title = serializers.CharField(source='challenge.title', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    class Meta:
        model = UserChallengeProgress
        fields = [
            'id', 'user', 'username', 'challenge', 'challenge_title',
            'is_completed', 'completion_date'
        ]
        read_only_fields = ['user', 'completion_date']

class UserGameSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserGameSession
        fields = ['id', 'user', 'game', 'started_at', 'completed_at', 'score']
        read_only_fields = ['started_at']
