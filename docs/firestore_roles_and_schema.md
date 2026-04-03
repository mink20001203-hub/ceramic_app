# Firestore 권한/데이터 구조 가이드

이 문서는 판매자 기능 기준으로 `role`, 컬렉션 구조, 주문 상태 필드, 보안 규칙 의도를 정리합니다.

## 1) Role 모델

`users/{uid}.role` 값:

- `user`: 일반 구매자
- `seller`: 판매자
- `admin`: 관리자

앱 내부(`lib/models/user_data_manager.dart`)도 동일하게 `UserRole.user/seller/admin`를 사용합니다.

기본 정책:

- 일반 사용자는 자기 문서 생성/수정 가능
- 일반 사용자는 자기 role 승격 불가
- `admin`만 다른 사용자 role 변경 가능

## 2) 컬렉션 구조

현재/권장 구조:

- `users/{uid}`
  - 앱 사용자 상태(이름, 마일리지, role 등)
  - 앱은 현재 주문/주소/결제수단 일부를 이 문서에 함께 저장
- `products/{productId}`
  - 판매 상품
- `orders/{orderId}` (권장/확장용)
  - 판매자 대시보드/정산/주문 분리를 위한 상위 컬렉션
- `coupons/{couponId}`
  - 쿠폰 마스터

## 3) 주문 데이터 필드(판매자 처리 확장)

주문 주요 필드:

- `status`: `결제완료 | 배송준비 | 배송중 | 배송완료 | 취소요청 | 취소완료`
- `trackingNumber` (`string?`): 송장번호
- `shippingMemo` (`string?`): 배송 메모
- `shippedAt` (`datetime?`): 발송 처리 시각
- `cancelReason` (`string?`): 취소 사유
- `canceledAt` (`datetime?`): 취소 처리 시각
- `statusLogs[]`: 상태 변경 로그(`status`, `date`, `actor`)

## 4) 보안 규칙 개요

적용 파일: `firestore.rules`

핵심 정책:

- `users`
  - `read`: 본인 또는 관리자
  - `create`: 본인만 가능 + self-create 시 role은 `user`만 허용
  - `update`: 본인은 role 변경 불가, 관리자는 전체 수정 가능
- `products`
  - `read`: 전체 공개
  - `write`: `seller` 또는 `admin`
- `orders`
  - `create`: 로그인 + `buyerId == auth.uid`
  - `read`: `buyerId`/`sellerId` 당사자 또는 관리자
  - `update`: 판매자/관리자, 또는 구매자의 `취소요청` 상태 변경
  - `delete`: 관리자만
- `coupons`
  - `read`: 로그인 사용자
  - `write`: 관리자만

## 5) 운영 체크포인트

- 판매자 계정은 Firebase Console에서 `users/{uid}.role = "seller"`로 지정
- `admin@ceramic.com`, `seller@ceramic.com`은 앱 로컬 fallback에서도 role 매핑
- Rules 배포 전/후 Emulator 또는 테스트 계정으로 다음을 점검:
  - 일반 유저의 role 승격 시도 차단
  - 판매자 상품 CRUD 허용
  - 일반 유저 상품 write 차단
  - 주문 취소요청/판매자 취소완료 흐름 허용
