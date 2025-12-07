# Run demo script for Linguaplay
# Opens two PowerShell windows: one for backend (Django) and one for frontend (Flutter)
# Usage: Right-click -> Run with PowerShell, or from PowerShell: .\run_demo.ps1

$repo = "C:\Users\user\Downloads\!!my_site"
$backendCmd = "cd '$repo'; .\\ms_env\\Scripts\\Activate.ps1; python manage.py runserver 0.0.0.0:8000"
$frontendCmd = "cd '$repo\\frontend\\linguaplay_app'; flutter pub get; flutter run"

Write-Host "Starting backend in a new PowerShell window..."
Start-Process -FilePath powershell -ArgumentList "-NoExit","-Command","$backendCmd"

Start-Sleep -Seconds 2
Write-Host "Starting frontend in a new PowerShell window..."
Start-Process -FilePath powershell -ArgumentList "-NoExit","-Command","$frontendCmd"

Write-Host "Launched backend and frontend. If an Android emulator is used, ensure ApiService.baseUrl is 'http://10.0.2.2:8000/api' in frontend/service."