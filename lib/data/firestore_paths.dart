// Firestore 컬렉션/문서 경로 정의 (Firebase Spark 기준)
// 실제 연결 시 여기를 기준으로 스키마를 고정한다.
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

  // coupons/{couponId}
  static const String coupons = 'coupons';
}
