# Analyze Environment Troubleshooting (Windows)

## Symptoms
- `flutter analyze` hangs or times out.
- `dart analyze` fails with access denied under `%APPDATA%\\.dart-tool`.

## Root Cause Observed
- Permission issue on `C:\Users\jeone\AppData\Roaming\.dart-tool`.
- Wrapper scripts may attempt bootstrap/update flows that can stall.

## Safe Workaround
Use direct Dart SDK binary and isolated APPDATA path:

```powershell
$env:APPDATA='C:\ceramic_app\.appdata'
New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
& "C:\Users\jeone\Downloads\flutter_windows_3.38.3-stable\flutter\bin\cache\dart-sdk\bin\dart.exe" --version
```

## If Access Denied Persists
1. Close all lingering Dart/Flutter processes.
```powershell
Get-Process | Where-Object { $_.ProcessName -like '*flutter*' -or $_.ProcessName -like 'dart*' } | Stop-Process -Force
```
2. Unblock Flutter bin files.
```powershell
Get-ChildItem -Path "C:\Users\jeone\Downloads\flutter_windows_3.38.3-stable\flutter\bin" -Recurse -File | Unblock-File -ErrorAction SilentlyContinue
```
3. Retry `flutter --no-version-check build web --release --base-href /ceramic_app/`.

## Long-term Fix
- Move Flutter SDK from `Downloads` to a stable writable path (e.g. `C:\dev\flutter`).
- Re-point PATH to new SDK bin.
- Re-run `flutter doctor`.
