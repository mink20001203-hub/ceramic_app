# Seller Order Filter Verification

Date: 2026-04-08

## Scope

- seller product list filtering
- seller order list filtering
- seller detail screen access consistency

## Current Logic Summary

1. Seller orders are loaded by `orders.sellerId` query.
2. Seller scope IDs are unified via `currentSellerScopeIds()` in `UserDataManager`.
3. Legacy/seed aliases are supported:
- `seller@ceramic.com`: own UID + `seller_demo` + `seller_uid`
- `seller2@ceramic.com`: own UID + `seller_uid_2`
4. Seller dashboard list filtering uses the same scope IDs for products and orders.

## Data Snapshot (audit:sellers)

- products total: 12
- orders total: 20
- products by seller:
  - `seller_uid`: 5
  - `seller_uid_2`: 5
  - `seller_demo`: 2
- orders by seller:
  - `seller_demo`: 17
  - `seller_uid`: 2
  - `seller_uid_2`: 1
- unknown seller docs: none

## Audit Command

Run from `C:\ceramic_app\scripts`:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\ceramic_app\keys\ceramic-app-aadcb-firebase-adminsdk-fbsvc-63445c802e.json"
$env:GOOGLE_CLOUD_PROJECT="ceramic-app-aadcb"
npm run audit:sellers
```

Pass criteria:
- `unknownProductSellerDocs` = `[]`
- `unknownOrderSellerDocs` = `[]`

## Manual Verification Steps

### seller1
1. login as `seller@ceramic.com`
2. open seller dashboard
3. verify only seller1 scope orders/products are visible
4. open order detail and process status

### seller2
1. login as `seller2@ceramic.com`
2. open seller dashboard
3. verify seller1-only records are not visible
4. open order detail and process status

## Final PASS Criteria

1. Seller cannot access other seller's records.
2. Seller detail actions (ship/cancel) apply only to visible orders.
3. Alias compatibility (`seller_uid`, `seller_uid_2`, `seller_demo`) works without leakage.
