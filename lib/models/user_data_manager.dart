import 'package:flutter/material.dart';
import 'product.dart';

// 사용자/세션 상태를 한 곳에서 관리하는 클래스.
// 화면에 필요한 데이터를 라우트마다 넘기지 않도록 중앙 집중화한다.

// --- 1. 장바구니 아이템 모델 (기존 유지) ---
class CartItem {
  final Product product;
  final String? option;
  int quantity;
  CartItem({required this.product, this.option, this.quantity = 1});
}

// --- 2. 리뷰 데이터 모델 (사진 경로 및 업데이트 대응) ---
class Review {
  final String productId;
  final String productName;
  final double rating;
  final String comment;
  final DateTime date;
  final String? imagePath; // ✅ 사진 경로 추가

  Review({
    required this.productId,
    required this.productName,
    required this.rating,
    required this.comment,
    required this.date,
    this.imagePath, // ✅ 선택 사항으로 추가
  });
}

// --- 2-1. 주문 아이템/주문 모델 ---
class OrderItem {
  final Product product;
  final String? option;
  final int quantity;
  final int unitPrice;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.option,
  });
}

class Order {
  final String id;
  final List<OrderItem> items;
  final int totalAmount;
  final int discountAmount;
  final int mileageUsed;
  final String? couponTitle;
  final DateTime date;
  String status; // 예: 결제완료/배송준비/배송중/배송완료
  final List<OrderStatusLog> statusLogs;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    required this.mileageUsed,
    this.couponTitle,
    required this.date,
    required this.status,
    required this.statusLogs,
  });
}

class OrderStatusLog {
  final String status;
  final DateTime date;
  final String actor; // 변경 주체(관리자/시스템)

  OrderStatusLog(
      {required this.status, required this.date, required this.actor});
}

// --- 2-2. 주소/결제수단 모델 ---
class Address {
  final String id;
  final String label;
  final String recipient;
  final String addressLine;
  final String phone;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.recipient,
    required this.addressLine,
    required this.phone,
    this.isDefault = false,
  });
}

class PaymentMethod {
  final String id;
  final String label;
  final String type; // 예: CARD/NAVER/KAKAO

  PaymentMethod({
    required this.id,
    required this.label,
    required this.type,
  });
}

// --- 2-3. 쿠폰 모델 ---
class Coupon {
  final String id;
  final String title;
  final int discountAmount;
  final int minOrderAmount;
  final List<String> allowedCategories; // 적용 가능한 카테고리
  final List<String> allowedProductIds; // 적용 가능한 상품 ID
  bool isUsed;

  Coupon({
    required this.id,
    required this.title,
    required this.discountAmount,
    required this.minOrderAmount,
    this.allowedCategories = const [],
    this.allowedProductIds = const [],
    this.isUsed = false,
  });
}

// --- 3. 통합 데이터 관리 클래스 ---
class UserDataManager with ChangeNotifier {
  // [로그인 및 사용자 정보 관리]
  bool _isLoggedIn = false;
  String _userName = "손님";
  int _mileage = 1500;
  int _reviewCount = 2;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  int get mileage => _mileage;
  int get reviewCount => _reviewCount;

  // 전체 상품 목록 (UI 공통 사용)
  final List<Product> _products = [];
  List<Product> get products => _products;

  // 배송지/결제수단 데이터
  final List<Address> _addresses = [
    Address(
      id: 'addr1',
      label: '집',
      recipient: '손님',
      addressLine: '서울시 강남구 테헤란로 123',
      phone: '010-1234-5678',
    ),
    Address(
      id: 'addr2',
      label: '회사',
      recipient: '손님',
      addressLine: '서울시 서초구 서초대로 45',
      phone: '010-9876-5432',
    ),
  ];
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(id: 'pm1', label: '신용카드', type: 'CARD'),
    PaymentMethod(id: 'pm2', label: '네이버페이', type: 'NAVER'),
    PaymentMethod(id: 'pm3', label: '카카오페이', type: 'KAKAO'),
  ];
  final List<Coupon> _coupons = [
    Coupon(
        id: 'c1',
        title: '웰컴 5,000원',
        discountAmount: 5000,
        minOrderAmount: 30000,
        allowedCategories: ['컵', '접시']),
    Coupon(
        id: 'c2',
        title: '세일 10,000원',
        discountAmount: 10000,
        minOrderAmount: 70000,
        allowedProductIds: ['p9', 'p10']),
  ];
  String _selectedAddressId = '';
  String _selectedPaymentId = '';
  String? _selectedCouponId;

  // 앱 시작 시 더미 상품과 기본 선택값을 준비한다.
  UserDataManager() {
    _products.addAll(dummyProducts);
    if (_addresses.isNotEmpty) {
      _selectedAddressId = _addresses.first.id;
    }
    if (_paymentMethods.isNotEmpty) {
      _selectedPaymentId = _paymentMethods.first.id;
    }
  }

  List<Address> get addresses => _addresses;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<Coupon> get coupons => _coupons;
  int get availableCouponCount => _coupons.where((c) => !c.isUsed).length;

  // 현재 선택된 배송지/결제수단
  Address? get selectedAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere((a) => a.id == _selectedAddressId,
        orElse: () => _addresses.first);
  }
  PaymentMethod? get selectedPayment {
    if (_paymentMethods.isEmpty) return null;
    return _paymentMethods.firstWhere((p) => p.id == _selectedPaymentId,
        orElse: () => _paymentMethods.first);
  }

  Coupon? get selectedCoupon {
    if (_selectedCouponId == null) return null;
    return _coupons.firstWhere((c) => c.id == _selectedCouponId,
        orElse: () => _coupons.first);
  }

  // 배송지/결제수단 선택 변경
  void setSelectedAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  void setSelectedPayment(String id) {
    _selectedPaymentId = id;
    notifyListeners();
  }

  // 쿠폰 선택/해제
  void setSelectedCoupon(String? id) {
    _selectedCouponId = id;
    notifyListeners();
  }

  void useCoupon(String? id) {
    if (id == null) return;
    for (final coupon in _coupons) {
      if (coupon.id == id) {
        coupon.isUsed = true;
        break;
      }
    }
    notifyListeners();
  }

  // 배송지 삭제
  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_addresses.isEmpty) {
      _selectedAddressId = '';
    } else if (_selectedAddressId == id) {
      _selectedAddressId = _addresses.first.id;
    }
    notifyListeners();
  }

  // 결제수단 삭제
  void removePaymentMethod(String id) {
    _paymentMethods.removeWhere((p) => p.id == id);
    if (_paymentMethods.isEmpty) {
      _selectedPaymentId = '';
    } else if (_selectedPaymentId == id) {
      _selectedPaymentId = _paymentMethods.first.id;
    }
    notifyListeners();
  }

  // 배송지 추가
  void addAddress(Address address) {
    _addresses.add(address);
    _selectedAddressId = address.id;
    notifyListeners();
  }

  // 배송지 수정
  void updateAddress(Address updated) {
    final index = _addresses.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _addresses[index] = updated;
      notifyListeners();
    }
  }

  // 기본 배송지 변경
  void setDefaultAddress(String id) {
    if (_addresses.any((a) => a.id == id)) {
      _selectedAddressId = id;
      notifyListeners();
    }
  }

  // 결제수단 추가
  void addPaymentMethod(PaymentMethod method) {
    _paymentMethods.add(method);
    _selectedPaymentId = method.id;
    notifyListeners();
  }

  // 결제수단 수정
  void updatePaymentMethod(PaymentMethod method) {
    final index = _paymentMethods.indexWhere((p) => p.id == method.id);
    if (index != -1) {
      _paymentMethods[index] = method;
      notifyListeners();
    }
  }

  // 기본 결제수단 변경
  void setDefaultPayment(String id) {
    if (_paymentMethods.any((p) => p.id == id)) {
      _selectedPaymentId = id;
      notifyListeners();
    }
  }

  void login() {
    // 서버 연동 없이 로그인 상태만 토글하는 데모 로직.
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    // 로그아웃 시 기본 사용자 상태로 되돌린다.
    _isLoggedIn = false;
    _userName = "손님";
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  // 탭 관리
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;
  void setTabIndex(int index) {
    // 네비게이션 상태를 한 곳에서 관리해 화면을 단순화한다.
    _currentTabIndex = index;
    notifyListeners();
  }

  // 주문 목록
  final List<Order> _orders = [];
  List<Order> get orders => _orders;

  // 주문 목록에서 구매된 상품을 추출 (리뷰/마이페이지 표시용)
  List<Product> get purchasedProducts {
    final Map<String, Product> map = {};
    for (final order in _orders) {
      for (final item in order.items) {
        map[item.product.id] = item.product;
      }
    }
    return map.values.toList();
  }

  // 찜하기(위시리스트)
  final List<Product> _wishlist = [];
  List<Product> get wishlist => _wishlist;

  void toggleWishlist(Product product) {
    // 즐겨찾기 토글로 즉시 UI 피드백을 제공한다.
    _wishlist.contains(product)
        ? _wishlist.remove(product)
        : _wishlist.add(product);
    notifyListeners();
  }

  bool isFavorite(Product product) => _wishlist.contains(product);

  // --- 장바구니 로직 (기존 유지) ---
  final List<CartItem> _cartWithQuantity = [];
  List<CartItem> get items => _cartWithQuantity;

  // 장바구니 담기: 품절/재고 초과 방지
  void addToCart(Product product, {String? selectedOption}) {
    if (product.stock == 0) return;
    // 이미 담긴 상품이면 수량만 증가시켜 중복을 방지한다.
    for (var item in _cartWithQuantity) {
      if (item.product.id == product.id &&
          item.option == (selectedOption ?? item.option)) {
        if (item.quantity >= product.stock) return;
        item.quantity++;
        notifyListeners();
        return;
      }
    }
    _cartWithQuantity.add(
        CartItem(product: product, option: selectedOption, quantity: 1));
    notifyListeners();
  }

  void removeFromCart(Product product, {String? option}) {
    _cartWithQuantity.removeWhere(
        (item) => item.product.id == product.id && item.option == option);
    notifyListeners();
  }

  // 수량 증가: 재고 초과 방지
  void incrementQuantity(String productId, String? option) {
    for (var item in _cartWithQuantity) {
      if (item.product.id == productId && item.option == option) {
        if (item.quantity >= item.product.stock) return;
        item.quantity++;
        notifyListeners();
        return;
      }
    }
  }

  void decrementQuantity(String productId, String? option) {
    for (var item in _cartWithQuantity) {
      if (item.product.id == productId &&
          item.option == option &&
          item.quantity > 1) {
        item.quantity--;
        notifyListeners();
        return;
      }
    }
  }

  void removeSingleItem(String productId, String? option) {
    _cartWithQuantity
        .removeWhere((item) => item.product.id == productId && item.option == option);
    notifyListeners();
  }

  void clearCart() {
    _cartWithQuantity.clear();
    notifyListeners();
  }

  int get totalAmount {
    int total = 0;
    for (var item in _cartWithQuantity) {
      total += _getEffectivePrice(item.product) * item.quantity;
    }
    return total;
  }

  // 세일가가 있으면 세일가를 사용한다.
  int _getEffectivePrice(Product product) {
    if (product.isSale && product.salePrice != null) {
      return product.salePrice!;
    }
    return product.price;
  }

  // 쿠폰 할인 계산
  bool _isCouponApplicable(Coupon coupon, List<OrderItem> items, int subtotal) {
    if (coupon.isUsed) return false;
    if (subtotal < coupon.minOrderAmount) return false;
    if (coupon.allowedCategories.isNotEmpty) {
      final hasCategory = items.any(
          (item) => coupon.allowedCategories.contains(item.product.category));
      if (!hasCategory) return false;
    }
    if (coupon.allowedProductIds.isNotEmpty) {
      final hasProduct = items.any(
          (item) => coupon.allowedProductIds.contains(item.product.id));
      if (!hasProduct) return false;
    }
    return true;
  }

  int _calculateCouponDiscount(Coupon? coupon, int subtotal, List<OrderItem> items) {
    if (coupon == null) return 0;
    if (!_isCouponApplicable(coupon, items, subtotal)) return 0;
    return coupon.discountAmount;
  }

  // 마일리지 사용 금액 계산
  int _calculateMileageUsage(int requested, int subtotalAfterCoupon) {
    final maxUsable =
        _mileage < subtotalAfterCoupon ? _mileage : subtotalAfterCoupon;
    return requested > maxUsable ? maxUsable : requested;
  }

  // 주문 시 재고 차감
  void _decreaseStock(Product product, int quantity) {
    final newStock = product.stock - quantity;
    product.stock = newStock < 0 ? 0 : newStock;
  }

  // 장바구니 기반 주문 생성
  void placeOrderFromCart({String? couponId, int mileageUsed = 0}) {
    if (_cartWithQuantity.isEmpty) return;

    final items = _cartWithQuantity
        .map((item) => OrderItem(
              product: item.product,
              option: item.option,
              quantity: item.quantity,
              unitPrice: _getEffectivePrice(item.product),
            ))
        .toList();

    final subtotal = items.fold<int>(
        0, (sum, item) => sum + item.unitPrice * item.quantity);
    final coupon = couponId == null
        ? null
        : _coupons.firstWhere((c) => c.id == couponId,
            orElse: () => _coupons.first);
    final couponDiscount = _calculateCouponDiscount(coupon, subtotal, items);
    final mileageToUse =
        _calculateMileageUsage(mileageUsed, subtotal - couponDiscount);
    final total = subtotal - couponDiscount - mileageToUse;

    for (final item in items) {
      _decreaseStock(item.product, item.quantity);
    }

    _orders.add(Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      totalAmount: total,
      discountAmount: couponDiscount,
      mileageUsed: mileageToUse,
      couponTitle: couponDiscount > 0 ? coupon?.title : null,
      date: DateTime.now(),
      status: '결제완료',
      statusLogs: [
        OrderStatusLog(
            status: '결제완료', date: DateTime.now(), actor: '시스템'),
      ],
    ));

    if (couponDiscount > 0) {
      useCoupon(couponId);
    }
    if (mileageToUse > 0) {
      _mileage -= mileageToUse;
    }

    _mileage += 500;
    clearCart();
    notifyListeners();
  }

  // 단일 상품 즉시구매
  void placeSingleOrder(Product product,
      {String? option, String? couponId, int mileageUsed = 0}) {
    final items = [
      OrderItem(
        product: product,
        option: option,
        quantity: 1,
        unitPrice: _getEffectivePrice(product),
      ),
    ];

    final subtotal = items.first.unitPrice;
    final coupon = couponId == null
        ? null
        : _coupons.firstWhere((c) => c.id == couponId,
            orElse: () => _coupons.first);
    final couponDiscount = _calculateCouponDiscount(coupon, subtotal, items);
    final mileageToUse =
        _calculateMileageUsage(mileageUsed, subtotal - couponDiscount);
    final total = subtotal - couponDiscount - mileageToUse;

    _decreaseStock(product, 1);

    _orders.add(Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      totalAmount: total,
      discountAmount: couponDiscount,
      mileageUsed: mileageToUse,
      couponTitle: couponDiscount > 0 ? coupon?.title : null,
      date: DateTime.now(),
      status: '결제완료',
      statusLogs: [
        OrderStatusLog(
            status: '결제완료', date: DateTime.now(), actor: '시스템'),
      ],
    ));

    if (couponDiscount > 0) {
      useCoupon(couponId);
    }
    if (mileageToUse > 0) {
      _mileage -= mileageToUse;
    }

    _mileage += 500;
    notifyListeners();
  }

  // 주문 상태 전환
  static const List<String> _orderStatuses = [
    '결제완료',
    '배송준비',
    '배송중',
    '배송완료',
  ];

  // 주문 상태를 다음 단계로 진행 (관리자 UI에서 사용)
  void advanceOrderStatus(String orderId, {String actor = '관리자'}) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    final currentIndex = _orderStatuses.indexOf(order.status);
    if (currentIndex >= 0 && currentIndex < _orderStatuses.length - 1) {
      final nextStatus = _orderStatuses[currentIndex + 1];
      order.status = nextStatus;
      order.statusLogs.add(
          OrderStatusLog(status: nextStatus, date: DateTime.now(), actor: actor));
      notifyListeners();
    }
  }

  // 주문 상태를 특정 값으로 변경 (확장용)
  void setOrderStatus(String orderId, String status, {String actor = '관리자'}) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    if (order.status != status) {
      order.status = status;
      order.statusLogs.add(
          OrderStatusLog(status: status, date: DateTime.now(), actor: actor));
      notifyListeners();
    }
  }

  // --- 리뷰 로직 (수정 및 1회 제한 기능 추가) ---
  final List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  // ✅ 1. 특정 상품 리뷰 존재 여부 확인 (hasReview 에러 해결)
  bool hasReview(String productId) {
    return _reviews.any((r) => r.productId == productId);
  }

  // ✅ 2. 특정 상품 리뷰 가져오기 (getReview 에러 해결)
  Review? getReview(String productId) {
    try {
      return _reviews.firstWhere((r) => r.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // ✅ 3. 리뷰 추가 (imagePath 파라미터 추가)
  void addReview(
      String productId, String productName, double rating, String comment,
      {String? imagePath}) {
    // 데모이므로 업로드 없이 이미지 경로만 보관한다.
    _reviews.add(Review(
      productId: productId,
      productName: productName,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
      imagePath: imagePath,
    ));

    _mileage += 100;
    _reviewCount++;
    notifyListeners();
  }

  // ✅ 4. 리뷰 수정 (updateReview 에러 해결)
  void updateReview(
      String productId, double rating, String comment, String? imagePath) {
    final index = _reviews.indexWhere((r) => r.productId == productId);
    if (index != -1) {
      _reviews[index] = Review(
        productId: productId,
        productName: _reviews[index].productName,
        rating: rating,
        comment: comment,
        date: DateTime.now(), // 수정일 기준 갱신
        imagePath: imagePath,
      );
      notifyListeners();
    }
  }
}
