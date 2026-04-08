// Firestore 컬렉션/문서 경로 정의
// 실제 연결 시 경로를 고정해서 화면과 데이터 구조를 일치시킨다.
class FirestorePaths {
  // users/{userId}
  static const String users = 'users';

  // products/{productId}
  static const String products = 'products';

  // orders/{orderId}
  static const String orders = 'orders';

  // users/{userId}/addresses/{addressId}
  static const String addresses = 'addresses';

  // users/{userId}/paymentMethods/{paymentId}
  static const String paymentMethods = 'paymentMethods';

  // users/{userId}/reviews/{reviewId}
  static const String reviews = 'reviews';

  // users/{userId}/coupons/{couponId}
  static const String userCoupons = 'coupons';

  // users/{userId}/mileageLogs/{logId}
  static const String mileageLogs = 'mileageLogs';

  // coupons/{couponId}
  static const String coupons = 'coupons';
}
