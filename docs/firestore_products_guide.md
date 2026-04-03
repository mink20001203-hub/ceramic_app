# Firestore 상품 데이터 가이드

이 문서는 `products` 컬렉션에 샘플 상품을 등록해서 앱에서 바로 확인하는 방법을 정리합니다.

## 1) 컬렉션 구조

경로:

- `products/{productId}`

필수 필드:

- `title` (`string`): 상품명
- `subTitle` (`string`): 부제목/요약
- `price` (`number`): 정상가
- `category` (`string`): 카테고리 (`컵`, `접시`, `볼`, `화병` 등)
- `stock` (`number`): 재고 수량
- `isNew` (`bool`): 신상품 여부
- `isSale` (`bool`): 할인 여부
- `options` (`array<string>`): 옵션 목록

선택 필드:

- `image` (`string | null`): 에셋 경로 또는 URL
- `salePrice` (`number | null`): 할인 가격 (`isSale=true`일 때 권장)
- `createdAt` (`timestamp`): 생성 시간

현재 앱은 `lib/repositories/product_repository.dart`에서 위 필드를 읽습니다.

## 2) 샘플 문서 예시

문서 ID 예시: `p_oud_001`

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
  "options": ["Small (220ml)", "Medium (320ml)"],
  "createdAt": "serverTimestamp"
}
```

문서 ID 예시: `p_oud_002`

```json
{
  "title": "모스 그린 세라믹 볼",
  "subTitle": "Olive Stoneware / Matte",
  "price": 92000,
  "salePrice": null,
  "image": "assets/images/plate.jpg",
  "category": "볼",
  "stock": 8,
  "isNew": false,
  "isSale": false,
  "options": ["1ea", "2ea Set"],
  "createdAt": "serverTimestamp"
}
```

## 3) Firebase Console에서 등록하는 방법

1. Firebase Console -> Firestore Database 이동
2. `products` 컬렉션 생성
3. `문서 추가`로 상품 문서 생성
4. 필드를 위 스키마대로 입력
5. 최소 5개 이상 등록 후 앱 새로고침

권장:

- `image`는 지금 앱 구조상 `assets/images/...` 경로를 넣으면 바로 표시됩니다.
- 외부 URL 이미지를 쓰려면 `Image.network` 대응이 추가로 필요합니다.

## 4) 앱과 연결 확인

`lib/main.dart`의 값이 아래처럼 되어 있어야 Firestore를 읽습니다.

```dart
const bool kUseRemoteProducts = true;
```

확인 순서:

1. 앱 실행
2. 홈 화면에서 상품 개수 확인
3. 카테고리 화면에서 등록 카테고리별 표시 확인
4. 상세 화면 진입/장바구니/주문 흐름 확인

## 5) 자주 발생하는 이슈

- 상품이 1개만 보임: Firestore에 1개만 등록된 상태
- 상품이 0개로 보임: 보안 규칙 또는 프로젝트 연결 문제
- 이미지 안 보임: `image` 경로 오타 또는 파일 미존재
- 할인 가격 미표시: `isSale`와 `salePrice` 조합 불일치

## 6) 시연용 권장 데이터 수

- 최소: 5개
- 권장: 10~20개
- 카테고리별 2~3개 이상 배치 권장

## 7) 판매자 데모 화면 사용 순서

1. `admin@ceramic.com` 계정으로 로그인
2. 마이페이지 -> `판매자 데모 관리` 진입
3. `상품 등록/관리` 탭에서 새 상품 등록
4. 같은 탭의 등록 상품 목록에서 가격/재고 수정 또는 삭제
5. 구매 테스트 주문 생성 후 `주문 관리` 탭에서 상태 변경

관련 파일:

- `lib/screens/seller_demo_screen.dart`
- `lib/models/user_data_manager.dart`

## 8) 자동 시드 스크립트 사용

자동 등록 파일:

- `scripts/seed_products_firestore.mjs`
- `scripts/seed_products.sample.json`
- `scripts/seed_products_README.md`

실행 순서:

1. 서비스 계정 키 경로를 `GOOGLE_APPLICATION_CREDENTIALS`로 설정
2. `cd scripts`
3. `npm install`
4. `npm run seed:products`

전체 초기화 + 재등록:

- `npm run seed:products:wipe`

## 9) 권한/스키마 참고 문서

- `docs/firestore_roles_and_schema.md`
- 판매자 role(`seller`) / 관리자 role(`admin`) 권한 정책과 컬렉션 구조를 함께 정리했습니다.
