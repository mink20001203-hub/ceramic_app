import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

// 사용자/세션 상태를 한 곳에서 관리하는 클래스.
// 화면에 필요한 데이터를 라우트마다 넘기지 않도록 중앙 집중화한다.

// 사용자 권한 구분 (관리자/일반 사용자)
enum UserRole { user, admin }

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
  final String addressSummary;
  final String paymentMethodLabel;
  final String paymentStatus; // 결제대기/결제완료/결제실패
  final bool agreementAccepted;
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
    required this.addressSummary,
    required this.paymentMethodLabel,
    required this.paymentStatus,
    required this.agreementAccepted,
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
  final String requestNote;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.recipient,
    required this.addressLine,
    required this.phone,
    this.requestNote = '',
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
  String? _userId;
  UserRole _role = UserRole.user;
  String _userName = "손님";
  int _mileage = 1500;
  int _reviewCount = 2;
  final bool _firebaseReady;
  FirebaseAuth? _auth;
  FirebaseFirestore? _db;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  UserRole get role => _role;
  bool get isAdmin => _role == UserRole.admin;
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
      requestNote: '문 앞에 두고 연락주세요',
    ),
    Address(
      id: 'addr2',
      label: '회사',
      recipient: '손님',
      addressLine: '서울시 서초구 서초대로 45',
      phone: '010-9876-5432',
      requestNote: '경비실에 맡겨주세요',
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
  UserDataManager({bool firebaseReady = false})
      : _firebaseReady = firebaseReady {
    if (_firebaseReady) {
      _auth = FirebaseAuth.instance;
      _db = FirebaseFirestore.instance;
    }
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
    _persist();
    notifyListeners();
  }

  void setSelectedPayment(String id) {
    _selectedPaymentId = id;
    _persist();
    notifyListeners();
  }

  // 쿠폰 선택/해제
  void setSelectedCoupon(String? id) {
    _selectedCouponId = id;
    _persist();
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
    _persist();
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
    _persist();
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
    _persist();
    notifyListeners();
  }

  // 배송지 추가
  void addAddress(Address address) {
    _addresses.add(address);
    _selectedAddressId = address.id;
    _persist();
    notifyListeners();
  }

  // 배송지 수정
  void updateAddress(Address updated) {
    final index = _addresses.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _addresses[index] = updated;
      _persist();
      notifyListeners();
    }
  }

  // 기본 배송지 변경
  void setDefaultAddress(String id) {
    if (_addresses.any((a) => a.id == id)) {
      _selectedAddressId = id;
      _persist();
      notifyListeners();
    }
  }

  // 결제수단 추가
  void addPaymentMethod(PaymentMethod method) {
    _paymentMethods.add(method);
    _selectedPaymentId = method.id;
    _persist();
    notifyListeners();
  }

  // 결제수단 수정
  void updatePaymentMethod(PaymentMethod method) {
    final index = _paymentMethods.indexWhere((p) => p.id == method.id);
    if (index != -1) {
      _paymentMethods[index] = method;
      _persist();
      notifyListeners();
    }
  }

  // 기본 결제수단 변경
  void setDefaultPayment(String id) {
    if (_paymentMethods.any((p) => p.id == id)) {
      _selectedPaymentId = id;
      _persist();
      notifyListeners();
    }
  }

  // 회원가입: Firebase Auth 계정 생성 + 사용자 데이터 초기 저장
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!_firebaseReady) {
      _isLoggedIn = true;
      _userId = email;
      _userName = name;
      _role = email.toLowerCase() == 'admin@ceramic.com'
          ? UserRole.admin
          : UserRole.user;
      notifyListeners();
      return;
    }

    final cred = await _auth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    _isLoggedIn = true;
    _userId = cred.user?.uid;
    _userName = name;
    _role = email.toLowerCase() == 'admin@ceramic.com'
        ? UserRole.admin
        : UserRole.user;
    try {
      await _persist();
    } catch (_) {
      // 네트워크/Firestore 오류가 있어도 로그인/회원가입 자체는 유지한다.
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    // Firebase 연결이 없으면 로컬 모드로 로그인한다.
    if (!_firebaseReady) {
      _isLoggedIn = true;
      _userId = email;
      _role = email.toLowerCase() == 'admin@ceramic.com'
          ? UserRole.admin
          : UserRole.user;
      notifyListeners();
      return;
    }

    await _auth!.signInWithEmailAndPassword(email: email, password: password);

    _isLoggedIn = true;
    _userId = _auth!.currentUser?.uid;
    _role = email.toLowerCase() == 'admin@ceramic.com'
        ? UserRole.admin
        : UserRole.user;
    try {
      await _loadFromBackend();
      await _persist();
    } catch (_) {
      // Firestore 오프라인 등으로 실패해도 로그인은 성공 처리
    }
    notifyListeners();
  }

  void logout() {
    // 로그아웃 시 기본 사용자 상태로 되돌린다.
    _isLoggedIn = false;
    _userId = null;
    _role = UserRole.user;
    _userName = "손님";
    if (_firebaseReady) {
      _auth?.signOut();
    }
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    _persist();
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
    _persist();
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
        _persist();
        notifyListeners();
        return;
      }
    }
    _cartWithQuantity.add(
        CartItem(product: product, option: selectedOption, quantity: 1));
    _persist();
    notifyListeners();
  }

  void removeFromCart(Product product, {String? option}) {
    _cartWithQuantity.removeWhere(
        (item) => item.product.id == product.id && item.option == option);
    _persist();
    notifyListeners();
  }

  // 수량 증가: 재고 초과 방지
  void incrementQuantity(String productId, String? option) {
    for (var item in _cartWithQuantity) {
      if (item.product.id == productId && item.option == option) {
        if (item.quantity >= item.product.stock) return;
        item.quantity++;
        _persist();
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
        _persist();
        notifyListeners();
        return;
      }
    }
  }

  void removeSingleItem(String productId, String? option) {
    _cartWithQuantity
        .removeWhere((item) => item.product.id == productId && item.option == option);
    _persist();
    notifyListeners();
  }

  void clearCart() {
    _cartWithQuantity.clear();
    _persist();
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
  void placeOrderFromCart(
      {String? couponId,
      int mileageUsed = 0,
      Address? address,
      PaymentMethod? payment,
      bool agreementAccepted = false}) {
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
      addressSummary: address == null
          ? '배송지 없음'
          : '${address.recipient} | ${address.phone}\n${address.addressLine}',
      paymentMethodLabel: payment?.label ?? '결제수단 없음',
      paymentStatus: '결제완료',
      agreementAccepted: agreementAccepted,
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
    _persist();
    notifyListeners();
  }

  // 단일 상품 즉시구매
  void placeSingleOrder(Product product,
      {String? option,
      String? couponId,
      int mileageUsed = 0,
      Address? address,
      PaymentMethod? payment,
      bool agreementAccepted = false}) {
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
      addressSummary: address == null
          ? '배송지 없음'
          : '${address.recipient} | ${address.phone}\n${address.addressLine}',
      paymentMethodLabel: payment?.label ?? '결제수단 없음',
      paymentStatus: '결제완료',
      agreementAccepted: agreementAccepted,
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
    _persist();
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
      _persist();
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
      _persist();
      notifyListeners();
    }
  }

  // --- 리뷰 로직 (수정 및 1회 제한 기능 추가) ---
  final List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  // 리뷰 삭제
  void removeReviewAt(int index) {
    _reviews.removeAt(index);
    if (_reviewCount > 0) _reviewCount--;
    _persist();
    notifyListeners();
  }

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

  // 리뷰에 연결된 최근 주문 찾기
  Order? getLatestOrderForProduct(String productId) {
    Order? latest;
    for (final order in _orders) {
      final hasProduct =
          order.items.any((item) => item.product.id == productId);
      if (hasProduct) {
        if (latest == null || order.date.isAfter(latest.date)) {
          latest = order;
        }
      }
    }
    return latest;
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
    _persist();
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
      _persist();
      notifyListeners();
    }
  }

  Future<void> _loadFromBackend() async {
    if (!_firebaseReady || _userId == null) return;
    final doc = await _db!.collection('users').doc(_userId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    _userName = data['userName'] ?? _userName;
    _mileage = data['mileage'] ?? _mileage;
    _reviewCount = data['reviewCount'] ?? _reviewCount;
    final roleStr = data['role'] as String? ?? 'user';
    _role = roleStr == 'admin' ? UserRole.admin : UserRole.user;

    _addresses
      ..clear()
      ..addAll((data['addresses'] as List<dynamic>? ?? [])
          .map((e) => _addressFromMap(Map<String, dynamic>.from(e))));
    _paymentMethods
      ..clear()
      ..addAll((data['paymentMethods'] as List<dynamic>? ?? [])
          .map((e) => _paymentFromMap(Map<String, dynamic>.from(e))));
    _reviews
      ..clear()
      ..addAll((data['reviews'] as List<dynamic>? ?? [])
          .map((e) => _reviewFromMap(Map<String, dynamic>.from(e))));
    _orders
      ..clear()
      ..addAll((data['orders'] as List<dynamic>? ?? [])
          .map((e) => _orderFromMap(Map<String, dynamic>.from(e))));

    final usedCoupons = (data['usedCoupons'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toSet();
    for (final c in _coupons) {
      c.isUsed = usedCoupons.contains(c.id);
    }
  }

  Future<void> _persist() async {
    if (!_firebaseReady || _userId == null) return;
    final data = {
      'userName': _userName,
      'mileage': _mileage,
      'reviewCount': _reviewCount,
      'role': _role == UserRole.admin ? 'admin' : 'user',
      'addresses': _addresses.map(_addressToMap).toList(),
      'paymentMethods': _paymentMethods.map(_paymentToMap).toList(),
      'reviews': _reviews.map(_reviewToMap).toList(),
      'orders': _orders.map(_orderToMap).toList(),
      'usedCoupons': _coupons.where((c) => c.isUsed).map((c) => c.id).toList(),
    };
    await _db!.collection('users').doc(_userId).set(data, SetOptions(merge: true));
  }

  Map<String, dynamic> _addressToMap(Address a) => {
        'id': a.id,
        'label': a.label,
        'recipient': a.recipient,
        'addressLine': a.addressLine,
        'phone': a.phone,
        'requestNote': a.requestNote,
      };

  Address _addressFromMap(Map<String, dynamic> m) => Address(
        id: m['id'],
        label: m['label'],
        recipient: m['recipient'],
        addressLine: m['addressLine'],
        phone: m['phone'],
        requestNote: m['requestNote'] ?? '',
      );

  Map<String, dynamic> _paymentToMap(PaymentMethod p) => {
        'id': p.id,
        'label': p.label,
        'type': p.type,
      };

  PaymentMethod _paymentFromMap(Map<String, dynamic> m) => PaymentMethod(
        id: m['id'],
        label: m['label'],
        type: m['type'],
      );

  Map<String, dynamic> _reviewToMap(Review r) => {
        'productId': r.productId,
        'productName': r.productName,
        'rating': r.rating,
        'comment': r.comment,
        'date': r.date.toIso8601String(),
        'imagePath': r.imagePath,
      };

  Review _reviewFromMap(Map<String, dynamic> m) => Review(
        productId: m['productId'],
        productName: m['productName'],
        rating: (m['rating'] as num).toDouble(),
        comment: m['comment'],
        date: DateTime.parse(m['date']),
        imagePath: m['imagePath'],
      );

  Map<String, dynamic> _orderItemToMap(OrderItem i) => {
        'product': _productToMap(i.product),
        'option': i.option,
        'quantity': i.quantity,
        'unitPrice': i.unitPrice,
      };

  OrderItem _orderItemFromMap(Map<String, dynamic> m) => OrderItem(
        product: _productFromMap(Map<String, dynamic>.from(m['product'])),
        option: m['option'],
        quantity: m['quantity'],
        unitPrice: m['unitPrice'],
      );

  Map<String, dynamic> _orderToMap(Order o) => {
        'id': o.id,
        'items': o.items.map(_orderItemToMap).toList(),
        'totalAmount': o.totalAmount,
        'discountAmount': o.discountAmount,
        'mileageUsed': o.mileageUsed,
        'couponTitle': o.couponTitle,
        'addressSummary': o.addressSummary,
        'paymentMethodLabel': o.paymentMethodLabel,
        'paymentStatus': o.paymentStatus,
        'agreementAccepted': o.agreementAccepted,
        'date': o.date.toIso8601String(),
        'status': o.status,
        'statusLogs': o.statusLogs.map(_orderLogToMap).toList(),
      };

  Order _orderFromMap(Map<String, dynamic> m) => Order(
        id: m['id'],
        items: (m['items'] as List<dynamic>)
            .map((e) => _orderItemFromMap(Map<String, dynamic>.from(e)))
            .toList(),
        totalAmount: m['totalAmount'],
        discountAmount: m['discountAmount'],
        mileageUsed: m['mileageUsed'],
        couponTitle: m['couponTitle'],
        addressSummary: m['addressSummary'],
        paymentMethodLabel: m['paymentMethodLabel'],
        paymentStatus: m['paymentStatus'],
        agreementAccepted: m['agreementAccepted'] ?? false,
        date: DateTime.parse(m['date']),
        status: m['status'],
        statusLogs: (m['statusLogs'] as List<dynamic>)
            .map((e) => _orderLogFromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Map<String, dynamic> _orderLogToMap(OrderStatusLog l) => {
        'status': l.status,
        'date': l.date.toIso8601String(),
        'actor': l.actor,
      };

  OrderStatusLog _orderLogFromMap(Map<String, dynamic> m) => OrderStatusLog(
        status: m['status'],
        date: DateTime.parse(m['date']),
        actor: m['actor'],
      );

  Map<String, dynamic> _productToMap(Product p) => {
        'id': p.id,
        'title': p.title,
        'subTitle': p.subTitle,
        'price': p.price,
        'image': p.image,
        'category': p.category,
        'salePrice': p.salePrice,
      };

  Product _productFromMap(Map<String, dynamic> m) => Product(
        id: m['id'],
        title: m['title'],
        subTitle: m['subTitle'],
        price: m['price'],
        image: m['image'],
        category: m['category'],
        salePrice: m['salePrice'],
      );
}
