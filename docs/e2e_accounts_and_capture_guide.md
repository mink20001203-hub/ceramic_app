# E2E Account and Capture Guide

Date: 2026-04-08
Project: `ceramic-app-aadcb`

## 1. Account Setup

Prepare four test accounts in Firestore `users/{uid}`.

1. `admin`
- email: `admin@ceramic.com`
- role: `admin`
- purpose: role change, global visibility

2. `seller`
- email: `seller@ceramic.com`
- role: `seller`
- uid example: `seller_uid`
- purpose: seller order processing

3. `seller2`
- email: `seller2@ceramic.com`
- role: `seller`
- uid example: `seller_uid_2`
- purpose: seller isolation verification

4. `user`
- email: `user@ceramic.com`
- role: `user`
- uid example: `user_uid`
- purpose: purchase and cancel request flow

## 2. E2E Checklist

### A. User flow
1. Login as `user`
2. Create order from checkout
3. Open order detail
4. Tap `취소 요청`
5. Verify order status becomes `취소요청`
6. Verify status log has a new row with actor `구매자`

### B. Seller flow
1. Login as `seller`
2. Open seller order list
3. Verify only own seller orders are visible
4. Open seller order detail
5. Enter tracking number and tap `발송 처리`
6. Verify status is `배송중` and tracking number is saved
7. For cancel scenario, tap `취소 완료 처리`
8. Verify status is `취소완료` and cancel reason is saved

### C. Admin flow
1. Login as `admin`
2. Open `판매자 권한 관리`
3. Change a test user role `user -> seller`
4. Verify role is updated in `users/{uid}.role`
5. Revert role to original value

## 3. Screenshot Rules

### Folder
- `C:\ceramic_app\captures\YYYYMMDD_e2e`

### Naming
- Format: `NN_role_action_result.png`
- Examples:
  - `01_user_login_pass.png`
  - `02_user_cancel_request_pass.png`
  - `03_seller_order_list_own_only_pass.png`
  - `04_seller_ship_complete_pass.png`
  - `05_seller_cancel_complete_pass.png`
  - `06_admin_role_change_pass.png`

### Required captures
1. User order detail with `취소요청`
2. Seller order detail with tracking number
3. Seller order detail with `취소완료`
4. Admin role dropdown before/after change

## 4. PASS Criteria

1. User cannot set `취소완료` directly
2. Seller can process ship and cancel for own orders
3. Seller list shows only own orders
4. Admin can change role and non-admin cannot
5. Every status change appends `statusLogs`

## 5. Fail Handling

1. Save screenshot with suffix `_fail`
2. Record repro steps in `docs/e2e_capture_report_template.md`
3. Mark final decision as `NO-GO` until fixed
