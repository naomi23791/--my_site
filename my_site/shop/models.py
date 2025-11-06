from django.db import models
from django.contrib.auth.models import User
from django.urls import reverse
from django.core.exceptions import ValidationError

class Language(models.Model):
    """Model for languages available in the app."""
    name = models.CharField(max_length=100, verbose_name="Language Name")
    code = models.CharField(max_length=10, unique=True, verbose_name="ISO Code (e.g., EN, FR)")
    flag_icon = models.CharField(max_length=50, blank=True, verbose_name="Flag Icon")

    class Meta:
        verbose_name = "Language"
        verbose_name_plural = "Languages"

    def __str__(self):
        return self.name

class Game(models.Model):
    """Model for games (quizzes, memory games, etc.)."""
    class Difficulty(models.IntegerChoices):
        EASY = 1, "Easy"
        MEDIUM = 2, "Medium"
        DIFFICULT = 3, "Difficult"
        EXPERT = 4, "Expert"
        LEGENDARY = 5, "Legendary"

    GAMETYPE_CHOICES = [
        ('QUIZ', "Quiz"),
        ('MEMORY', "Memory Game"),
        ('WORD_SEARCH', "Word Search"),
        ('LISTENING', "Listening Comprehension"),
    ]

    title = models.CharField(max_length=200, verbose_name="Game Title")
    game_type = models.CharField(max_length=20, choices=GAMETYPE_CHOICES, verbose_name="Game Type")
    description = models.TextField(blank=True, verbose_name="Description")
    language = models.ForeignKey(Language, on_delete=models.CASCADE, verbose_name="Associated Language", db_index=True)
    difficulty = models.IntegerField(
        choices=Difficulty.choices,
        default=Difficulty.EASY,
        verbose_name="Difficulty Level (1-5)",
    )
    is_external = models.BooleanField(default=False, verbose_name="Is External Game")
    external_url = models.URLField(blank=True, null=True, verbose_name="External Game URL")

    class Meta:
        verbose_name = "Game"
        verbose_name_plural = "Games"

    def __str__(self):
        return f"{self.title} ({self.language.name})"

class UserProfile(models.Model):
    """Extension of Django's User model."""
    user = models.OneToOneField(User, on_delete=models.CASCADE, verbose_name="User")
    languages_learning = models.ManyToManyField(Language, verbose_name="Languages being Learned")
    current_streak = models.IntegerField(default=0, verbose_name="Current Learning Streak (days)")
    total_points = models.IntegerField(default=0, verbose_name="Total Points")
    avatar = models.ImageField(upload_to='avatars/', blank=True, verbose_name="Avatar")

    class Meta:
        verbose_name = "User Profile"
        verbose_name_plural = "User Profiles"

    def __str__(self):
        return self.user.username

class Challenge(models.Model):
    """Model for daily or special challenges."""
    title = models.CharField(max_length=200, verbose_name="Challenge Title")
    description = models.TextField(verbose_name="Challenge Description")
    language = models.ForeignKey(Language, on_delete=models.CASCADE, verbose_name="Language", db_index=True)
    points_reward = models.IntegerField(default=10, verbose_name="Reward Points")
    is_daily = models.BooleanField(default=False, verbose_name="Is Daily Challenge")
    start_date = models.DateTimeField(verbose_name="Start Date")
    end_date = models.DateTimeField(verbose_name="End Date")

    class Meta:
        verbose_name = "Challenge"
        verbose_name_plural = "Challenges"

    def clean(self):
        if self.end_date < self.start_date:
            raise ValidationError("End date should be after start date.")

    def __str__(self):
        return f"{self.title} ({self.language.name})"

class UserChallengeProgress(models.Model):
    """Tracks user progress in challenges."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name="User", db_index=True)
    challenge = models.ForeignKey(Challenge, on_delete=models.CASCADE, verbose_name="Challenge", db_index=True)
    is_completed = models.BooleanField(default=False, verbose_name="Challenge Completed")
    completion_date = models.DateTimeField(blank=True, null=True, verbose_name="Completion Date")

    class Meta:
        verbose_name = "User Challenge Progress"
        verbose_name_plural = "User Challenge Progresses"
        unique_together = ('user', 'challenge')

    def __str__(self):
        return f"{self.user.username} - {self.challenge.title}"

class Reward(models.Model):
    """Model for rewards (badges, levels, etc.)."""
    name = models.CharField(max_length=100, verbose_name="Reward Name")
    description = models.TextField(blank=True, verbose_name="Description")
    icon = models.CharField(max_length=100, verbose_name="Reward Icon")
    points_required = models.IntegerField(default=0, verbose_name="Points Required to Unlock")

    class Meta:
        verbose_name = "Reward"
        verbose_name_plural = "Rewards"

    def __str__(self):
        return self.name

class UserReward(models.Model):
    """Links unlocked rewards to users."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name="User", db_index=True)
    reward = models.ForeignKey(Reward, on_delete=models.CASCADE, verbose_name="Reward", db_index=True)
    unlocked_at = models.DateTimeField(auto_now_add=True, verbose_name="Unlock Date")

    class Meta:
        verbose_name = "User Reward"
        verbose_name_plural = "User Rewards"
        unique_together = ('user', 'reward')

    def __str__(self):
        return f"{self.user.username} - {self.reward.name}"

# Log user interaction with games (native OR external)
class UserGameSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name="User")
    game = models.ForeignKey(Game, on_delete=models.CASCADE, verbose_name="Game")
    started_at = models.DateTimeField(auto_now_add=True, verbose_name="Started At")
    completed_at = models.DateTimeField(blank=True, null=True, verbose_name="Completed At")
    score = models.FloatField(blank=True, null=True, verbose_name="Score")

    def __str__(self):
        return f"{self.user.username} - {self.game.title} session"
