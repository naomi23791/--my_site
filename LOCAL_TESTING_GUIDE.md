# LinguaPlay - Local Testing Guide

## Quick Start: Testing the Application Locally

This guide walks you through testing the LinguaPlay application end-to-end on your local machine.

---

## Prerequisites Checklist

- ✅ Django dev server running on localhost:8000
- ✅ Flutter SDK installed on your machine
- ✅ Android Emulator running OR physical device connected via USB
- ✅ All tests passing (backend: 4/4, frontend: 4/4)

---

## Step 1: Verify Backend Server is Running

### 1.1 Check if Server is Still Running

```powershell
# Check if Python processes are running
Get-Process | Where-Object { $_.Name -match 'python' } | Select-Object Name, Id

# Test API endpoint
Invoke-WebRequest -Uri http://localhost:8000/api/languages/ -UseBasicParsing
```

**Expected Output:** Status code 200

### 1.2 If Server is Not Running, Start It

```powershell
# Navigate to Django project
cd C:\Users\user\Downloads\!!my_site\my_site

# Start server in background (recommended) or new terminal
C:\Users\user\Downloads\!!my_site\ms_env\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

**Expected Output:**
```
Starting development server at http://127.0.0.1:8000/
Quit the server with CTRL-BREAK.
```

---

## Step 2: Run Flutter App

### 2.1 Check Connected Devices

```powershell
cd C:\Users\user\Downloads\!!my_site\frontend\linguaplay_app

flutter devices
```

**Expected Output:**
```
2 connected devices:

emulator-5554              • emulator-5554                                     • android • Android 11 (API 30)
Samsung Galaxy S21        • XXXXXXXXXXX                                       • android • Android 12
```

### 2.2 Launch the App

```powershell
# Option A: Let Flutter choose device (if only one is available)
flutter run

# Option B: Specify a device
flutter run -d emulator-5554

# Option C: Run in release mode (faster)
flutter run --release
```

**Expected Output:**
```
✓ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing and launching...
```

Once the app launches on your device/emulator, you'll see the **Login Screen**.

---

## Step 3: Test User Registration & Login

### 3.1 Register New User

1. Tap **"S'inscrire"** (Register) button
2. Enter credentials:
   - **Email:** testuser@example.com
   - **Password:** TestPassword123!
   - **Confirm Password:** TestPassword123!
3. Tap **Register**

**Expected Behavior:**
- Request sent to `POST /auth/register/`
- Backend creates user and returns auth token
- Token saved locally in SharedPreferences
- App navigates to **Home Screen** automatically

### 3.2 Test Login (if you skip registration)

1. On Login Screen, enter:
   - **Email:** testuser@example.com
   - **Password:** TestPassword123!
2. Tap **Login**

**Expected Behavior:**
- Request sent to `POST /auth/login/`
- Backend validates credentials and returns token
- Token saved locally
- App navigates to **Home Screen**

---

## Step 4: Navigate to Games List

### 4.1 From Home Screen

1. Look for **"Jeux"** (Games) navigation option or button
2. Tap to navigate to `GamesListScreen`

**Expected Screen Elements:**
- AppBar with title "Jeux"
- Language selector (Dropdown)
- Grid of game cards

### 4.2 Select a Language

1. Tap the **language dropdown** at top
2. Select "English" or another language

**Expected Behavior:**
- Request sent to `GET /api/games/?language_id=<id>`
- Games list updates to show games in selected language
- Game cards appear in grid layout

### 4.3 Verify Games Data

Check the **Django server logs** for:
```
[DD/MMM/YYYY HH:MM:SS] "GET /api/games/?language_id=1 HTTP/1.1" 200
```

This confirms the Flutter app successfully communicated with the Django backend.

---

## Step 5: Test Game Session

### 5.1 Start a Game

1. Tap any **game card** in the grid
2. App navigates to `QuizScreen`

**Expected Screen Elements:**
- Game title in AppBar
- Game description
- "Démarrer le jeu" (Start Game) button

### 5.2 Start Game Session

1. Tap **"Démarrer le jeu"** button

**Expected Behavior:**
- Request sent to `POST /api/usergamesession/start/` with game_id
- Backend creates game session record
- UI updates to show "Partie en cours..." (Game in progress)
- Session ID displayed

### 5.3 Verify in Django Admin

Open Django admin to confirm session was created:

```powershell
# (Optional) Open Django admin in browser
# navigate to http://localhost:8000/admin
# Login with superuser credentials if available
```

---

## Step 6: Test User Profile

### 6.1 Navigate to Profile

1. From any screen, find **Profile** navigation option
2. Tap to navigate to `ProfileScreen`

**Expected Screen Elements:**
- User avatar (circular)
- Username
- Total XP count
- User level
- Selected languages list
- Settings button

### 6.2 Verify Profile Data

The profile screen fetches user data from `GET /api/profiles/me/`.

**Check Django server logs:**
```
[DD/MMM/YYYY HH:MM:SS] "GET /api/profiles/me/ HTTP/1.1" 200
```

---

## Step 7: Verify Network Requests in Real-Time

### 7.1 Monitor Django Server Logs

Keep the Django server terminal window visible to see incoming requests:

```
[DD/MMM/YYYY HH:MM:SS] "POST /auth/register/ HTTP/1.1" 201
[DD/MMM/YYYY HH:MM:SS] "GET /api/languages/ HTTP/1.1" 200
[DD/MMM/YYYY HH:MM:SS] "GET /api/games/ HTTP/1.1" 200
[DD/MMM/YYYY HH:MM:SS] "POST /api/usergamesession/start/ HTTP/1.1" 201
[DD/MMM/YYYY HH:MM:SS] "GET /api/profiles/me/ HTTP/1.1" 200
```

### 7.2 Check Database Changes (Optional)

Use Django shell to query the database:

```powershell
cd C:\Users\user\Downloads\!!my_site\my_site
C:\Users\user\Downloads\!!my_site\ms_env\Scripts\python.exe manage.py shell

# In the shell:
>>> from shop.models import UserGameSession, UserProfile
>>> UserGameSession.objects.all()
<QuerySet [<UserGameSession: UserGameSession object (1)>, ...]>
>>> UserProfile.objects.filter(user__email='testuser@example.com')
<QuerySet [<UserProfile: testuser>]>
```

---

## Troubleshooting

### Issue: "Connection refused" when app tries to connect

**Cause:** Django server not running or listening on wrong interface

**Solution:**
```powershell
# Kill any existing servers
Get-Process python | Stop-Process -Force

# Start fresh
cd C:\Users\user\Downloads\!!my_site\my_site
C:\Users\user\Downloads\!!my_site\ms_env\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

### Issue: Login fails with "Invalid credentials"

**Cause:** User doesn't exist in database or wrong password

**Solution:**
- Register a new account first, or
- Use Django admin to reset password:
  ```powershell
  C:\Users\user\Downloads\!!my_site\ms_env\Scripts\python.exe manage.py changepassword testuser
  ```

### Issue: Games list is empty

**Cause:** No games exist for selected language in database

**Solution:**
- Check data in database:
  ```powershell
  C:\Users\user\Downloads\!!my_site\ms_env\Scripts\python.exe manage.py shell
  # >>> from shop.models import Game, Language
  # >>> Language.objects.all()
  # >>> Game.objects.filter(language__code='en')
  ```
- Or add test data via Django admin

### Issue: Flutter app crashes

**Cause:** Provider or model mismatch

**Solution:**
1. Check Flutter logs for specific error:
   ```powershell
   flutter logs
   ```
2. Run tests to identify the issue:
   ```powershell
   flutter test
   ```
3. Check that all providers are registered in `main.dart`

---

## Test Scenarios

### Scenario 1: Full User Journey (Recommended)
1. ✅ Register new account
2. ✅ View available languages
3. ✅ Browse games in English
4. ✅ View game details
5. ✅ Start a game session
6. ✅ View user profile
7. ✅ Verify data in Django admin

**Expected Time:** 5-10 minutes

### Scenario 2: Rapid Testing (Quick Verification)
1. ✅ Login with existing account
2. ✅ Load games (verify API call in Django logs)
3. ✅ Start a game session (verify session created in Django)
4. ✅ View profile

**Expected Time:** 2-3 minutes

---

## Verify Integration Success

### Checklist for Successful Integration

- [ ] Django server running (see HTTP 200 responses in logs)
- [ ] Flutter app launches without errors
- [ ] User registration works (new user in database)
- [ ] User login works (token generated)
- [ ] Languages API returns data
- [ ] Games API returns data
- [ ] Game session created in database
- [ ] Profile data retrieved and displayed
- [ ] No provider errors in Flutter logs
- [ ] No 500 errors in Django logs

**If all items are checked:** ✅ **Integration is successful!**

---

## Additional Testing

### Run Automated Tests

```powershell
# Backend tests
cd C:\Users\user\Downloads\!!my_site\my_site
C:\Users\user\Downloads\!!my_site\ms_env\Scripts\python.exe manage.py test shop.tests

# Frontend tests
cd C:\Users\user\Downloads\!!my_site\frontend\linguaplay_app
flutter test
```

### Code Quality Checks

```powershell
# Flutter analysis
cd C:\Users\user\Downloads\!!my_site\frontend\linguaplay_app
flutter analyze

# Format code
flutter format lib/ test/
```

---

## Recording Test Results

For your university submission, document:

1. **Screenshots:**
   - Login screen
   - Games list screen with loaded games
   - Game detail/quiz screen
   - Profile screen with user data

2. **Video/Screen Recording:**
   - Full user flow from registration to game completion
   - Show Django server logs during interaction

3. **Test Report:**
   - Backend tests: 4/4 passing
   - Frontend tests: 4/4 passing
   - API connectivity: ✅ Verified
   - Database: ✅ User and session data saved

---

## Support & Debugging

### Enable Verbose Logging

```powershell
# Flutter
flutter run -v

# Django
# Set DEBUG=True in settings.py (already set for dev)
```

### Check API Directly

```powershell
# Get languages
Invoke-WebRequest -Uri http://localhost:8000/api/languages/ | Select-Object StatusCode, Content

# Get games
Invoke-WebRequest -Uri http://localhost:8000/api/games/ | Select-Object StatusCode, Content

# With authentication (replace TOKEN with actual token)
$headers = @{
    'Authorization' = 'Bearer YOUR_TOKEN_HERE'
}
Invoke-WebRequest -Uri http://localhost:8000/api/profiles/me/ -Headers $headers
```

---

## Success!

Once you've completed this guide, you will have:
- ✅ Verified the backend is running and responding
- ✅ Tested user registration and authentication
- ✅ Confirmed frontend-to-backend integration
- ✅ Validated data persistence in the database
- ✅ Demonstrated the full application flow

**This completes the E2E (end-to-end) verification of the LinguaPlay application.**

---

*Last Updated:* 2024  
*Application Status:* ✅ Ready for Submission
