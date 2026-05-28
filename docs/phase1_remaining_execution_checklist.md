# Phase 1 Remaining Execution Checklist

Date: 2026-04-08
Project: `ceramic-app-aadcb`

This checklist is for completing the remaining Phase 1 items in order.

## 0. Preconditions

1. `npm run check:accounts` must be `PASS`.
2. Service account env vars must be set.
3. Firestore rules must be latest deployed version.

## 1. Korean Text / Copy Sweep

Goal: Remove broken text and incomplete copy from buyer/seller/admin screens.

Steps:
1. Run `npm run audit:strings` in `scripts`.
2. Open target screens and verify visible text manually.
3. Fix any broken strings in:
- home
- detail
- cart
- checkout
- order complete
- order detail
- my page
- benefit/coupon/mileage
- seller dashboard/detail
- admin role management
4. Run `flutter analyze lib`.

Done criteria:
- no broken strings in target flows
- `flutter analyze lib` passes

## 2. Real Account E2E with Capture Evidence

Goal: Finish end-to-end validation and save screenshots.

Steps:
1. Create folder: `C:\ceramic_app\captures\20260408_e2e`.
2. User flow (`user@ceramic.com`)
- login
- create order
- open order detail
- request cancel
- capture: `01_user_cancel_request_pass.png`
3. Seller flow (`seller@ceramic.com`)
- login
- open seller orders
- verify own orders only
- process shipping with tracking number
- process cancel complete on cancel-requested order
- captures:
  - `02_seller_order_list_own_only_pass.png`
  - `03_seller_ship_complete_pass.png`
  - `04_seller_cancel_complete_pass.png`
4. Admin flow (`admin@ceramic.com`)
- open role management
- change test user role and revert
- capture: `05_admin_role_change_pass.png`

Done criteria:
- all captures exist
- all checklist steps completed with PASS

## 3. Order/Payment/Cancel Integrity Audit

Goal: Verify no order schema/state inconsistencies remain.

Steps:
1. `npm run audit:orders`
2. Confirm result:
- `issueOrders=0`
- `warningOrders=0`

Done criteria:
- audit command exits success

## 4. Seller Data Partition Final Verification

Goal: Confirm seller-separated products/orders are valid and queryable.

Steps:
1. `npm run audit:sellers`
2. Confirm no unknown seller docs.
3. Manual UI check:
- seller account sees seller + legacy alias scope only
- seller2 account sees seller2 + alias scope only

Done criteria:
- audit command exits success
- manual UI verification PASS

## 5. Minimum Ops Docs Finalization

Goal: Finish minimum docs for ongoing operation.

Must update:
1. `docs/e2e_accounts_and_capture_guide.md`
2. `docs/account_preparation_matrix.md`
3. `docs/seller_order_filter_verification.md`
4. `docs/firestore_roles_and_schema.md`
5. `docs/e2e_execution_log_20260408.md` (new)

Done criteria:
- all docs updated with latest execution result and date

## 6. Final Verification Gate

Run in order:
1. `flutter analyze lib`
2. `npm run test:rules:localjdk`
3. `npm run audit:orders`
4. `npm run audit:sellers`

Go / No-Go:
- GO only if all commands pass and E2E captures are complete.
