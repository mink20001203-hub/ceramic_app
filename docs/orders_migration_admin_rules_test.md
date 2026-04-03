# 주문 컬렉션 마이그레이션 + 관리자 권한 도구

## 1) 적용 내용

- 주문 저장 위치를 `users/{uid}.orders` 배열에서 `orders/{orderId}` 상위 컬렉션으로 전환
- 로그인 시 `orders` 컬렉션 우선 로드
- `orders`가 비어 있고 `users.orders`가 남아있으면 자동 이관 후 `users.orders` 제거
- 관리자 전용 화면에서 사용자 role(`user/seller/admin`) 변경 가능

## 2) 앱 동작 기준

- 구매자: `buyerId == 내 uid` 주문만 조회
- 판매자/관리자: 전체 주문 조회
- 신규 주문 생성 시 `buyerId`, `sellerId`를 함께 저장

## 3) 관리자 화면

- 파일: `lib/screens/admin_role_management_screen.dart`
- 진입: 마이페이지 > 판매자 권한 관리 (admin만 노출)
- 기능: 사용자 목록 조회, role 변경, 즉시 반영

## 4) Firestore Rules Emulator 테스트

테스트 파일:

- `scripts/firestore_rules.test.mjs`

검증 항목:

- 일반 사용자 role 승격 차단
- 판매자 상품 생성 허용
- 일반 사용자 상품 생성 차단
- 구매자 취소요청 허용 / 취소완료 직접 변경 차단
- 판매자 주문 조회/상태 업데이트 허용
- 비로그인 사용자 users 접근 차단
- 관리자 role 변경 허용

실행:

```powershell
cd C:\ceramic_app\scripts
npm install
npm run test:rules
```
