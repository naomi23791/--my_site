import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:linguaplay_app/screens/profile/profile_screen.dart';
import 'package:linguaplay_app/providers/profile_provider.dart';
import 'package:linguaplay_app/models/profile_model.dart';

// Extend real ProfileProvider with test-friendly overrides
class TestProfileProvider extends ProfileProvider {
  TestProfileProvider(): super(apiService: null);

  UserProfile? _testProfile;

  void setTestProfile(UserProfile p) {
    _testProfile = p;
    notifyListeners();
  }

  @override
  UserProfile? get userProfile => _testProfile;

  @override
  Future<void> loadUserProfile() async {
    // noop
  }
}

void main() {
  testWidgets('ProfileScreen shows username when profile present', (WidgetTester tester) async {
    final pp = TestProfileProvider();
    pp.setTestProfile(UserProfile(
      id: 1,
      userId: 1,
      username: 'tester',
      avatarUrl: null,
      totalXP: 42,
      level: 3,
      selectedLanguages: [1, 2],
      gameStats: {'quiz': 100},
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    ));

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileProvider>.value(
        value: pp,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('tester'), findsOneWidget);
  });
}
