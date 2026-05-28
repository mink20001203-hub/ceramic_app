# Features

## 역할별 기능 요약

| 역할 | 기능 | 현재 상태 | 관련 화면/파일 |
| --- | --- | --- | --- |
| 구매자 | 상품 목록 조회 | 구현 | `lib/screens/home_screen.dart` |
| 구매자 | 카테고리별 상품 탐색 | 구현 | `lib/screens/category_screen.dart`, `lib/screens/category_result_screen.dart` |
| 구매자 | 상품 검색 | 구현 | `lib/screens/search_screen.dart` |
| 구매자 | 상품 상세 확인 | 구현 | `lib/screens/detail_screen.dart` |
| 구매자 | 장바구니 담기/수량 관리 | 구현 | `lib/screens/cart_screen.dart` |
| 구매자 | 주문/결제 플로우 | 구현 | `lib/screens/checkout_screen.dart`, `lib/screens/order_complete_screen.dart` |
| 구매자 | 주문 목록/상세 확인 | 구현 | `lib/screens/user_order_list_screen.dart`, `lib/screens/order_detail_screen.dart` |
| 구매자 | 주문 취소 요청 | 구현 | `lib/models/user_data_manager.dart`, `lib/screens/order_detail_screen.dart` |
| 구매자 | 쿠폰 확인/사용 | 구현 | `lib/screens/coupon_list_screen.dart` |
| 구매자 | 마일리지 내역 확인 | 구현 | `lib/screens/mileage_history_screen.dart` |
| 구매자 | 리뷰 작성/수정/관리 | 구현 | `lib/screens/review_manage_screen.dart`, `lib/models/user_data_manager.dart` |
| 구매자 | 프로필 수정 | 구현 | `lib/screens/profile_edit_screen.dart` |
| 구매자 | 주문/정책/쿠폰 알림 확인 | 구현 | `lib/screens/notification_list_screen.dart` |
| 판매자 | 판매자 전용 화면 진입 | 구현 | `lib/screens/seller_demo_screen.dart` |
| 판매자 | 본인 판매 범위 주문 조회 | 구현 | `lib/models/user_data_manager.dart`, `docs/seller_order_filter_verification.md` |
| 판매자 | 배송 상태 변경 | 구현 | `lib/screens/seller_order_detail_screen.dart` |
| 판매자 | 운송장 입력 | 구현 | `lib/screens/seller_order_detail_screen.dart` |
| 판매자 | 취소 요청 처리 | 구현 | `lib/screens/seller_order_detail_screen.dart` |
| 판매자 | 상품 등록/수정/삭제 | 구현 | `lib/screens/seller_demo_screen.dart` |
| 관리자 | 사용자 역할 조회/변경 | 구현 | `lib/screens/admin_role_management_screen.dart` |
| 관리자 | 정책/FAQ 운영 콘텐츠 관리 | 구현 | `lib/screens/admin_content_management_screen.dart` |
| 관리자 | Firestore rules 기준 관리자 권한 | 구현 | `firestore.rules` |

## 기능별 설명

### 구매자

구매자는 상품을 탐색하고 장바구니에 담은 뒤 주문을 생성할 수 있습니다. 주문 이후에는 주문 목록과 상세 화면에서 상태 로그, 결제 금액, 쿠폰/마일리지 적용 내역을 확인합니다.

리뷰와 마일리지는 `UserDataManager`에서 관리되며, Firestore 연결 시 사용자 하위 컬렉션에 저장됩니다.

### 판매자

판매자는 sellerId 기준으로 본인 판매 범위의 상품과 주문을 관리합니다. 기존 시드 데이터 호환을 위해 일부 seller alias를 함께 처리하는 로직이 있습니다.

관련 검증 문서: [seller_order_filter_verification.md](seller_order_filter_verification.md)

### 관리자

관리자는 사용자 role을 변경하고 정책/FAQ 데이터를 관리할 수 있습니다. 일반 사용자가 스스로 role을 변경하지 못하도록 Firestore rules에서 제한합니다.

## 확인 필요

| 항목 | 이유 |
| --- | --- |
| 최신 배포본에서 모든 화면이 정상 동작하는지 | README 작성 시점 이후 배포 상태 확인 필요 |
| 리뷰 기능의 전체 E2E 캡처 | 코드상 기능은 있으나 최신 수동 검증 로그 확인 필요 |
| 알림 기능의 전체 E2E 캡처 | `docs/e2e_profile_notification_checklist_20260414.md`에 미완료 항목 존재 |
