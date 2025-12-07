Presentation Guide — Linguaplay demo

Goal: start backend and frontend, log in with test credentials, run a quick quiz, and show score submission.

1) Start everything (quick)
- Double-click or run `run_demo.ps1` from the repo root. It opens two PowerShell windows:
  - Backend: runs Django at http://127.0.0.1:8000/
  - Frontend: runs Flutter (`flutter run`) (pick emulator/device)

2) If using Android emulator
- Edit `frontend/linguaplay_app/lib/services/api_service.dart` and set `baseUrl` to `http://10.0.2.2:8000/api` if needed.

3) Test credentials
- Username: `testuser`
- Password: `TestPass123!`

4) Demo steps to show in ~2 minutes
- Open the app on the emulator/device.
- Log in with test credentials.
- Choose a language (top dropdown) and tap a game.
- Tap "Démarrer le jeu", answer a couple of questions; show correct/incorrect highlights.
- Tap "Terminer et envoyer le score" and show success snackbar.
- Optionally open browser to `http://127.0.0.1:8000/admin/` (if you created a superuser) to show stored sessions/users.

5) If anything fails during the demo
- Copy the PowerShell output (backend / frontend windows) and paste it here; I will diagnose quickly.

6) Optional deliverables I can add now (say yes)
- Short GIF recorder command and a sample GIF for the README.
- A 1-page slide (PDF) with the app flow and marking points.
- Commit and create a zip of the repo ready for submission.

Good luck — dites-moi quelle option vous voulez pour la suite.