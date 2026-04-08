# Account Preparation Matrix

Date: 2026-04-08
Project: `ceramic-app-aadcb`

## Required Accounts (Current)

| Role | Email | UID | Firestore role | Status |
|---|---|---|---|---|
| Admin | admin@ceramic.com | YdckjGWjhkUEetjsJAkRE47kzb53 | admin | PASS |
| Seller 1 | seller@ceramic.com | 09QlrMbZHEhQC0OJjIxNEmvDejc2 | seller | PASS |
| Seller 2 | seller2@ceramic.com | kBrRQfQY8DfZBeDbb4rKcmua1q12 | seller | PASS |
| User | user@ceramic.com | 0z8VXCEfm8goEoy7LjT5qlmZP703 | user | PASS |

## Validation Command

Run from `C:\ceramic_app\scripts`:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\ceramic_app\keys\ceramic-app-aadcb-firebase-adminsdk-fbsvc-63445c802e.json"
$env:GOOGLE_CLOUD_PROJECT="ceramic-app-aadcb"
npm run check:accounts
```

Expected result:
- `admin/seller/seller2/user` all `PASS`

## Security Notes

1. Do not commit real passwords in git/docs.
2. Keep `DEMO_PASSWORD` only in local terminal env.
3. Rotate demo passwords after external demo sessions.
