# Firestore Schema

## 기준 파일

- Rules: `firestore.rules`
- Path constants: `lib/data/firestore_paths.dart`
- 상세 문서: [firestore_roles_and_schema.md](firestore_roles_and_schema.md)

## 역할 모델

`users/{uid}.role` 값으로 권한을 구분합니다.

| role | 의미 |
| --- | --- |
| `user` | 일반 구매자 |
| `seller` | 판매자 |
| `admin` | 관리자 |

핵심 정책:

- 일반 사용자는 본인 문서만 읽고 수정합니다.
- 일반 사용자는 자신의 `role`을 직접 승격할 수 없습니다.
- 판매자는 본인 sellerId와 연결된 상품/주문을 관리합니다.
- 관리자는 사용자 역할과 운영 데이터를 관리할 수 있습니다.

## 컬렉션 구조

```text
users/{uid}
users/{uid}/addresses/{addressId}
users/{uid}/paymentMethods/{paymentId}
users/{uid}/reviews/{reviewId}
users/{uid}/coupons/{couponId}
users/{uid}/mileageLogs/{logId}
products/{productId}
orders/{orderId}
coupons/{couponId}
policies/{policyId}
supportFaqs/{faqId}
```

## 접근 권한 요약

| 경로 | 읽기 | 생성 | 수정 | 삭제 |
| --- | --- | --- | --- | --- |
| `users/{uid}` | 본인, 관리자 | 본인만, role은 `user`만 | 본인(role 변경 불가), 관리자 | 관리자 |
| `users/{uid}/addresses/*` | 본인, 관리자 | 본인, 관리자 | 본인, 관리자 | 본인, 관리자 |
| `users/{uid}/paymentMethods/*` | 본인, 관리자 | 본인, 관리자 | 본인, 관리자 | 본인, 관리자 |
| `users/{uid}/reviews/*` | 본인, 관리자 | 본인, 관리자 | 본인, 관리자 | 본인, 관리자 |
| `users/{uid}/coupons/*` | 본인, 관리자 | 본인, 관리자 | 본인, 관리자 | 본인, 관리자 |
| `users/{uid}/mileageLogs/*` | 본인, 관리자 | 본인, 관리자 | 본인, 관리자 | 본인, 관리자 |
| `products/{productId}` | 전체 공개 | 판매자/관리자 | 판매자/관리자 | 판매자/관리자 |
| `orders/{orderId}` | 구매자, 판매자, 관리자 | 구매자 본인 주문 | 판매자/관리자, 구매자 취소 요청 | 관리자 |
| `coupons/{couponId}` | 로그인 사용자 | 관리자 | 관리자 | 관리자 |
| `policies/{policyId}` | 전체 공개 | 관리자 | 관리자 | 관리자 |
| `supportFaqs/{faqId}` | 전체 공개 | 관리자 | 관리자 | 관리자 |

## 주요 문서 예시

### users/{uid}

```json
{
  "email": "user@example.com",
  "name": "사용자",
  "role": "user",
  "mileage": 1000
}
```

### products/{productId}

```json
{
  "title": "오트 화이트 머그",
  "subTitle": "Handmade / Matte Finish",
  "price": 52000,
  "salePrice": 45000,
  "image": "assets/images/mug.jpg",
  "category": "컵",
  "stock": 12,
  "isNew": true,
  "isSale": true,
  "options": ["Small", "Medium"],
  "sellerId": "seller_uid"
}
```

### orders/{orderId}

```json
{
  "buyerId": "buyer_uid",
  "sellerId": "seller_uid",
  "items": [],
  "totalAmount": 52000,
  "status": "결제완료",
  "statusLogs": []
}
```

주문 상태:

| 상태 | 의미 |
| --- | --- |
| `결제완료` | 주문 생성 완료 |
| `배송준비` | 판매자 배송 준비 |
| `배송중` | 운송장 입력 후 배송 진행 |
| `배송완료` | 배송 완료 |
| `취소요청` | 구매자가 취소 요청 |
| `취소완료` | 판매자/관리자가 취소 처리 |

## 테스트

Firestore rules 테스트:

```powershell
cd scripts
npm run test:rules
```

Windows 로컬 JDK 우회 스크립트:

```powershell
cd scripts
npm run test:rules:localjdk
```

## 확인 필요

| 항목 | 이유 |
| --- | --- |
| 실제 운영 Firestore 인덱스 목록 | 레포 내 인덱스 문서 없음 |
| 배포된 rules와 로컬 `firestore.rules` 일치 여부 | Firebase 콘솔 또는 배포 로그 확인 필요 |
| demo 계정 UID와 seller alias 최신성 | 시드 데이터 변경 시 갱신 필요 |
