# Firestore Role / Schema Guide

Date: 2026-04-08
Project: `ceramic-app-aadcb`

## 1) Role model

`users/{uid}.role`:
- `user`: buyer
- `seller`: seller
- `admin`: operator

Core policy:
1. normal users cannot self-promote role
2. only admin can change other users' roles

## 2) Collections

- `users/{uid}`
- `products/{productId}`
- `orders/{orderId}`
- `coupons/{couponId}`

## 3) Order fields (required)

- `status`: one of
  - `결제완료`
  - `배송준비`
  - `배송중`
  - `배송완료`
  - `취소요청`
  - `취소완료`
- `buyerId`
- `sellerId`
- `items[]`
- `totalAmount`
- `statusLogs[]`

Optional operational fields:
- `trackingNumber`
- `shippingMemo`
- `shippedAt`
- `cancelReason`
- `canceledAt`

## 4) Seller scope and alias compatibility

Current app logic uses `currentSellerScopeIds()`:

- seller1 (`seller@ceramic.com`):
  - own UID
  - `seller_demo`
  - `seller_uid`
- seller2 (`seller2@ceramic.com`):
  - own UID
  - `seller_uid_2`

This is for backward compatibility with legacy/seed data and should be reduced after full UID migration.

## 5) Rules intent

Applied file: `firestore.rules`

- `users`
  - read: self or admin
  - create: self only, role must be `user`
  - update: self without role promotion, admin full
- `products`
  - read: public
  - write: seller/admin
- `orders`
  - create: authenticated + `buyerId == auth.uid`
  - read: buyer/seller/admin
  - update: seller/admin OR buyer cancellation request only
  - delete: admin only
- `coupons`
  - read: authenticated users
  - write: admin only

## 6) Operational verification commands

Run in `C:\ceramic_app\scripts`:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\ceramic_app\keys\ceramic-app-aadcb-firebase-adminsdk-fbsvc-63445c802e.json"
$env:GOOGLE_CLOUD_PROJECT="ceramic-app-aadcb"
npm run check:accounts
npm run audit:orders
npm run audit:sellers
npm run test:rules:localjdk
```

Pass gate:
- account check PASS
- order audit no issues/warnings
- seller audit unknown docs empty
- rules tests all pass
