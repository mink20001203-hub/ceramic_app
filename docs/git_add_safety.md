# git add 안전 가이드

`git add .` 전에 아래 명령을 먼저 실행한다.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\pre_commit_safety_check.ps1
```

## 동작

- 차단 파일 검사:
  - `serviceAccountKey.json`, `service-account*.json`, `client_secret*.json`
  - `.env`, `.env.*`
  - `*.pem`, `*.p12`, `*.jks`, `*.keystore`
  - `GoogleService-Info.plist`
- 경고 파일 검사:
  - `android/app/google-services.json`
  - `lib/firebase_options.dart`
- 스테이징된 diff 내용에서 개인키/토큰/시크릿 패턴 검사

## 권장 커밋 순서

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\pre_commit_safety_check.ps1
git add .
powershell -ExecutionPolicy Bypass -File .\scripts\pre_commit_safety_check.ps1
git status
git commit -m "커밋 메시지"
git push
```
