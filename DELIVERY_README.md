Delivery README — Linguaplay (student submission)

This document explains how to run the backend and frontend locally and includes test credentials for evaluation.

Prerequisites
- Python 3.11+ and pip
- Flutter SDK (for frontend) and an emulator or device
- On Windows: PowerShell is used in examples

Backend (Django)
1. Activate the provided virtualenv:

```powershell
cd 'c:\Users\user\Downloads\!!my_site'
.\ms_env\Scripts\Activate.ps1
```

2. Install deps (if needed):

```powershell
pip install -r requirements.txt
```

3. Apply migrations and create a test user (already provided in this repo, but steps shown):

```powershell
python manage.py migrate
python manage.py createsuperuser  # optional
```

4. Run the dev server:

```powershell
python manage.py runserver 0.0.0.0:8000
```

The API will be available at `http://127.0.0.1:8000/api/`.

Frontend (Flutter)
1. Open a new PowerShell and go to the flutter project:

```powershell
cd 'c:\Users\user\Downloads\!!my_site\frontend\linguaplay_app'
flutter pub get
```

2. Run the app (choose an emulator or device):

```powershell
flutter run
```

Notes for Android emulator: if the app needs to connect to the local Django server, use `http://10.0.2.2:8000/api` as `ApiService.baseUrl` (adjusted automatically if running on an emulator where necessary).

Test credentials (for demo)
- Username: `testuser`
- Password: `TestPass123!`

What I changed for the demo
- Backend: added a prototype endpoint `GET /api/games/<id>/questions/` that returns sample quiz questions (useful for the frontend quiz prototype).
- Frontend: added quiz UI that loads questions, shows correct/incorrect feedback, and sends final score to the backend.
- Tests: added a widget test `quiz_flow_test.dart` to exercise the quiz flow without network.

How to run tests (frontend)

```powershell
cd 'c:\Users\user\Downloads\!!my_site\frontend\linguaplay_app'
flutter test
```

How to run Django tests

```powershell
cd 'c:\Users\user\Downloads\!!my_site'
.\ms_env\Scripts\Activate.ps1
python manage.py test
```

If anything fails locally, please share the error messages and I will help fix them quickly.

Good luck for your presentation — tell me if you want a short demo GIF or a 1-page screenshot guide to attach to your submission.
