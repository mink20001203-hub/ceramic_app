// lib/product.dart 파일 전체 코드 (최종 구조 통일)
class Product {
  final String id; // ✅ 장바구니 삭제 시 필요한 고유 식별자
  final String title; // ✅ 상품명 (기존 name에서 변경됨)
  final String subTitle; // ✅ 상품 설명 (부제)
  final int price; // ✅ 가격 (숫자 타입)
  final String? image; // ✅ 이미지 경로 (없을 수 있으므로 null 허용)
  final String category; // ✅ 카테고리 필드 추가

  Product({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.price,
    this.image,
    required this.category,
  });
}

// ✅ 테스트를 위한 샘플 데이터 (필요에 따라 수정해서 사용하세요)
List<Product> dummyProducts = [
  Product(
      id: 'p1',
      title: '화이트 티컵',
      subTitle: '감성 티타임',
      price: 45000,
      image: 'assets/images/cup.jpg',
      category: '컵'),
  Product(
      id: 'p2',
      title: '모던 플레이트',
      subTitle: '미니멀 접시',
      price: 68000,
      image: 'assets/images/plate.jpg',
      category: '접시'),
  Product(
      id: 'p3',
      title: '흙 톤 머그잔',
      subTitle: '따뜻한 질감',
      price: 32000,
      image: 'assets/images/mug.jpg',
      category: '컵'),
];
