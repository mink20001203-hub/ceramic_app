# Seller Order Filter Verification

Date: 2026-04-08

## Scope
- Seller product list filtering
- Seller order list filtering
- Seller detail screen access consistency

## Current Logic Summary

1. Orders collection load for seller role
- query by `orders.sellerId`
- source: `UserDataManager._loadOrdersFromCollection()`

2. Seller IDs used for query
- default: current user uid
- compatibility: `seller@ceramic.com` includes `seller_demo`
- source: `UserDataManager._currentSellerIdsForQuery()`

3. Seller dashboard list filtering
- products: `product.sellerId == currentUserId` (and legacy `seller_demo` for demo seller)
- orders: `order.sellerId == currentUserId` (and legacy `seller_demo` for demo seller)
- source: `SellerDemoScreen`

## Data Preconditions

Seed data currently includes seller split:
- `seller_uid`: `p_oud_001` to `p_oud_005`
- `seller_uid_2`: `p_oud_006` to `p_oud_010`
- `seller_demo`: `p_oud_011`, `p_oud_012`

## Read-only Verification Snapshot

### Products by sellerId
- total: `12`
- `seller_uid`: `5`
- `seller_uid_2`: `5`
- `seller_demo`: `2`

### Orders by sellerId (existing legacy data)
- total: `18`
- `seller_demo`: `17`
- `seller_uid`: `1`

Note:
- Existing historical orders still mostly point to `seller_demo`.
- For strict seller isolation demo, create fresh orders from new seeded products for each seller.

## Manual Verification Steps

### seller_uid
1. Login as seller account mapped to uid `seller_uid`
2. Open seller dashboard
3. Confirm products from `seller_uid_2` are not visible
4. Create new user order for `seller_uid` product
5. Confirm order appears in seller list

### seller_uid_2
1. Login as seller2 account mapped to uid `seller_uid_2`
2. Open seller dashboard
3. Confirm products from `seller_uid` are not visible
4. Create new user order for `seller_uid_2` product
5. Confirm seller_uid orders are not visible

### seller_demo compatibility
1. Login as `seller@ceramic.com`
2. Confirm legacy `seller_demo` products/orders are visible
3. Confirm non-legacy unrelated seller data is not visible

## PASS Criteria

1. Seller can only see own `sellerId` records
2. seller1 and seller2 datasets are isolated
3. Legacy `seller_demo` compatibility only applies to demo seller account
4. Seller order detail actions (ship/cancel) only apply to visible orders

## Troubleshooting

1. If seller sees all orders, check role in `users/{uid}.role`
2. If seller sees no orders, check `orders.sellerId` values
3. If seller_demo legacy does not appear, confirm login email is exactly `seller@ceramic.com`
4. If product split is wrong, rerun seed:
- `npm run seed:products:wipe` (with project env set)
