# Products Firestore Migration Guide

## 목적

현재 로컬 더미 상품(`dummyProducts`)을 사용 중인 앱을, 나중에 Firestore `products` 컬렉션 기반으로 안전하게 전환하기 위한 가이드.

## 권장 스키마 (`products/{productId}`)

```json
{
  "title": "화이트 머그",
  "subTitle": "핸드메이드 질감",
  "price": 32000,
  "image": "assets/images/mug.jpg",
  "category": "컵",
  "stock": 10,
  "isNew": true,
  "isSale": false,
  "salePrice": null,
  "options": ["350ml", "420ml"]
}
```

## 전환 단계

1. Firestore에 `products` 컬렉션 생성 후 샘플 문서 20개 업로드
2. `firestore.rules`에서 `products` 읽기/쓰기 정책 확인
3. 앱에서 원격 상품 모드를 켜고(`setRemoteProductsEnabled(true)`) 홈/검색/상세 동작 확인
4. 원격 로딩 실패 시 로컬 폴백이 동작하는지 확인
5. 이상 없으면 기본값을 원격 모드로 전환

## 검증 포인트

- 문서 누락 필드가 있어도 앱이 크래시하지 않아야 함
- 카테고리/검색/상세/장바구니 진입이 모두 동작해야 함
- 재고 0 상품은 주문 제한이 유지되어야 함
