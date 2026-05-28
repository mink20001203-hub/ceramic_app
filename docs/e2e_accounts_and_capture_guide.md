# E2E Account and Capture Guide

Date: 2026-04-08
Project: `ceramic-app-aadcb`

## 1. Target Accounts

1. admin: `admin@ceramic.com`
2. seller: `seller@ceramic.com`
3. seller2: `seller2@ceramic.com`
4. user: `user@ceramic.com`

## 2. Pre-run Commands

Run from `C:\ceramic_app\scripts`:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\service-account.json"
$env:GOOGLE_CLOUD_PROJECT="ceramic-app-aadcb"
npm run check:accounts
npm run seed:orders:e2e:wipe
npm run audit:orders
npm run audit:sellers
```

Expected:
- account check `PASS`
- order audit `issueOrders=0`, `warningOrders=0`
- seller audit unknown docs empty

## 3. E2E Checklist

### A. User flow
1. login as `user`
2. create order from checkout
3. open order detail
4. tap `취소 요청`
5. verify status = `취소요청`
6. verify status log actor includes `구매자`

### B. Seller flow
1. login as `seller`
2. open seller order list
3. verify only own scope orders are visible
4. open seller order detail
5. input tracking number and tap `발송 처리`
6. verify status = `배송중`
7. process cancel complete for cancel-requested order
8. verify status = `취소완료` with reason

### C. Admin flow
1. login as `admin`
2. open role management
3. change a test user role (`user -> seller`)
4. verify role update in `users/{uid}.role`
5. revert to original role

## 4. Screenshot Rules

Folder:
- `C:\ceramic_app\captures\YYYYMMDD_e2e`

Naming format:
- `NN_role_action_result.png`

Required captures:
1. `01_user_cancel_request_pass.png`
2. `02_seller_order_list_own_only_pass.png`
3. `03_seller_ship_complete_pass.png`
4. `04_seller_cancel_complete_pass.png`
5. `05_admin_role_change_pass.png`

## 5. PASS Criteria

1. user cannot set `취소완료` directly
2. seller can process ship/cancel only in own scope
3. admin can change role and non-admin cannot
4. status changes append `statusLogs`
5. all required captures saved

## 6. Fail Handling

1. Save screenshot with `_fail` suffix.
2. Log reproduction steps in `docs/e2e_capture_report_template.md`.
3. Mark final decision as `NO-GO` until fixed.
