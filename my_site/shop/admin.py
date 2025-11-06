from django.contrib import admin
from django.utils.html import format_html
from django.utils import timezone
from .models import Language, Game, Challenge, Reward, UserProfile, UserChallengeProgress, UserReward


@admin.register(Language)
class LanguageAdmin(admin.ModelAdmin):
    list_display = ['name', 'code', 'display_flag']
    list_filter = ['code']
    search_fields = ['name', 'code']
    list_per_page = 20

    @admin.display(empty_value="-", description="Flag")
    def display_flag(self, obj):
        if obj.flag_icon:
            return format_html('<span style="font-size: 20px;">{}</span>', obj.flag_icon)
        return "-"


@admin.register(Game)
class GameAdmin(admin.ModelAdmin):
    list_display = ['title', 'game_type', 'language', 'difficulty', 'created']
    list_filter = ['game_type', 'language', 'difficulty']
    search_fields = ['title', 'description']
    list_per_page = 25

    @admin.display(description="Created")
    def created(self, obj):
        return "✓"


@admin.register(Challenge)
class ChallengeAdmin(admin.ModelAdmin):
    list_display = ['title', 'language', 'points_reward', 'daily_badge', 'status', 'date_range']
    list_filter = ['is_daily', 'language', 'start_date']
    search_fields = ['title', 'description']
    date_hierarchy = 'start_date'
    list_per_page = 30

    @admin.display(description="Type")
    def daily_badge(self, obj):
        if obj.is_daily:
            return format_html('<span style="background: #4CAF50; color: white; padding: 3px 8px; border-radius: 12px;">DAILY</span>')
        return format_html('<span style="background: #2196F3; color: white; padding: 3px 8px; border-radius: 12px;">SPECIAL</span>')

    @admin.display(description="Status")
    def status(self, obj):
        now = timezone.now()
        if obj.start_date <= now <= obj.end_date:
            return format_html('<span style="color: green; font-weight: bold;">● ACTIVE</span>')
        elif now < obj.start_date:
            return format_html('<span style="color: orange;">● UPCOMING</span>')
        else:
            return format_html('<span style="color: red;">● ENDED</span>')

    @admin.display(description="Date Range")
    def date_range(self, obj):
        return f"{obj.start_date.strftime('%d/%m')} - {obj.end_date.strftime('%d/%m')}"


@admin.register(Reward)
class RewardAdmin(admin.ModelAdmin):
    list_display = ['name', 'display_icon', 'points_required', 'unlock_count']
    list_filter = ['points_required']
    search_fields = ['name', 'description']

    @admin.display(empty_value="-", description="Icon")
    def display_icon(self, obj):
        if obj.icon:
            return format_html('<span style="font-size: 20px;">{}</span>', obj.icon)
        return "-"

    @admin.display(description="Unlocked By")
    def unlock_count(self, obj):
        return UserReward.objects.filter(reward=obj).count()


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['username', 'email', 'total_points', 'current_streak', 'languages_count', 'avatar_display']
    list_filter = ['current_streak']
    search_fields = ['user__username', 'user__email']
    list_per_page = 50

    @admin.display(description="Username")
    def username(self, obj):
        return obj.user.username

    @admin.display(description="Email")
    def email(self, obj):
        return obj.user.email

    @admin.display(description="Languages")
    def languages_count(self, obj):
        return obj.languages_learning.count()

    @admin.display(empty_value="-", description="Avatar")
    def avatar_display(self, obj):
        if obj.avatar:
            return format_html('<img src="{}" style="width: 30px; height: 30px; border-radius: 50%;" />', obj.avatar.url)
        return "-"


@admin.register(UserChallengeProgress)
class UserChallengeProgressAdmin(admin.ModelAdmin):
    list_display = ['username', 'challenge_title', 'language', 'completion_status', 'completion_date_display']
    list_filter = ['is_completed', 'challenge__language', 'completion_date']
    search_fields = ['user__username', 'challenge__title']
    date_hierarchy = 'completion_date'

    @admin.display(description="Username")
    def username(self, obj):
        return obj.user.username

    @admin.display(description="Challenge")
    def challenge_title(self, obj):
        return obj.challenge.title

    @admin.display(description="Language")
    def language(self, obj):
        return obj.challenge.language.name

    @admin.display(description="Status")
    def completion_status(self, obj):
        return "✓ COMPLETED" if obj.is_completed else "◌ IN PROGRESS"

    @admin.display(empty_value="-", description="Completed At")
    def completion_date_display(self, obj):
        return obj.completion_date.strftime("%d/%m/%Y %H:%M") if obj.completion_date else "-"


@admin.register(UserReward)
class UserRewardAdmin(admin.ModelAdmin):
    list_display = ['username', 'reward_name', 'reward_icon', 'points_required', 'unlocked_at_display']
    list_filter = ['reward', 'unlocked_at']
    search_fields = ['user__username', 'reward__name']
    date_hierarchy = 'unlocked_at'

    @admin.display(description="Username")
    def username(self, obj):
        return obj.user.username

    @admin.display(description="Reward")
    def reward_name(self, obj):
        return obj.reward.name

    @admin.display(empty_value="-", description="Icon")
    def reward_icon(self, obj):
        return format_html('<span style="font-size: 18px;">{}</span>', obj.reward.icon) if obj.reward.icon else "-"

    @admin.display(description="Points Required")
    def points_required(self, obj):
        return obj.reward.points_required

    @admin.display(empty_value="-", description="Unlocked At")
    def unlocked_at_display(self, obj):
        return obj.unlocked_at.strftime("%d/%m/%Y %H:%M") if obj.unlocked_at else "-"


# Actions personnalisées pour l'admin
def make_daily_challenge(modeladmin, request, queryset):
    queryset.update(is_daily=True)


make_daily_challenge.short_description = "Mark as daily challenge"


def reset_streaks(modeladmin, request, queryset):
    queryset.update(current_streak=0)


reset_streaks.short_description = "Reset streaks"

# Ajouter les actions aux modèles
ChallengeAdmin.actions = [make_daily_challenge]
UserProfileAdmin.actions = [reset_streaks]

# Personnalisation du titre de l'admin
admin.site.site_header = "🎯 LinguaPlay Administration"
admin.site.site_title = "LinguaPlay Admin Portal"
admin.site.index_title = "📊 LinguaPlay Dashboard"