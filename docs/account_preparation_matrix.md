# Account Preparation Matrix

Date: 2026-04-08
Project: `ceramic-app-aadcb`

## Required Accounts

| Role | Email | UID Example | Firestore role | Notes |
|---|---|---|---|---|
| Admin | admin@ceramic.com | admin_uid | admin | 운영/권한 변경 |
| Seller 1 | seller@ceramic.com | seller_uid | seller | legacy seller_demo 호환 계정 |
| Seller 2 | seller2@ceramic.com | seller_uid_2 | seller | 판매자 분리 검증 계정 |
| User | user@ceramic.com | user_uid | user | 구매/취소요청 검증 |

## Firestore User Doc Minimum Fields

Path: `users/{uid}`

Required fields:
- `userName`: string
- `email`: string
- `role`: `user | seller | admin`
- `mileage`: number

Example:
```json
{
  "userName": "판매자1",
  "email": "seller@ceramic.com",
  "role": "seller",
  "mileage": 0
}
```

## Pre-demo Checklist

1. All 4 accounts can login from app
2. `users/{uid}.role` matches matrix
3. `products` docs include `sellerId`
4. New order docs include `buyerId`, `sellerId`, `status`
5. Admin account can open `판매자 권한 관리`

## Security Notes

1. Do not commit real passwords in git/docs
2. Share password only in secure channel
3. Rotate demo passwords after external demo session
