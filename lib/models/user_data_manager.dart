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
  final DateTime date;
  String status; // 예: 결제완료/배송준비/배송중/배송완료
  final List<OrderStatusLog> statusLogs;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.date,
    required this.status,
    required this.statusLogs,
  });
}

class OrderStatusLog {
  final String status;
  final DateTime date;

  OrderStatusLog({required this.status, required this.date});
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
      isDefault: true,
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
  String _selectedAddressId = '';
  String _selectedPaymentId = '';

  UserDataManager() {
    _products.addAll(dummyProducts);
    if (_addresses.isNotEmpty) {
      _selectedAddressId =
          _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first).id;
    }
    if (_paymentMethods.isNotEmpty) {
      _selectedPaymentId = _paymentMethods.first.id;
    }
  }

  List<Address> get addresses => _addresses;
  List<PaymentMethod> get paymentMethods => _paymentMethods;

  Address? get selectedAddress =>
      _addresses.firstWhere((a) => a.id == _selectedAddressId, orElse: () => _addresses.first);
  PaymentMethod? get selectedPayment =>
      _paymentMethods.firstWhere((p) => p.id == _selectedPaymentId, orElse: () => _paymentMethods.first);

  void setSelectedAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  void setSelectedPayment(String id) {
    _selectedPaymentId = id;
    notifyListeners();
  }

  void addAddress(Address address) {
    _addresses.add(address);
    _selectedAddressId = address.id;
    notifyListeners();
  }

  void updateAddress(Address updated) {
    final index = _addresses.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _addresses[index] = updated;
      notifyListeners();
    }
  }

  void addPaymentMethod(PaymentMethod method) {
    _paymentMethods.add(method);
    _selectedPaymentId = method.id;
    notifyListeners();
  }

  void updatePaymentMethod(PaymentMethod method) {
    final index = _paymentMethods.indexWhere((p) => p.id == method.id);
    if (index != -1) {
      _paymentMethods[index] = method;
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

  int _getEffectivePrice(Product product) {
    if (product.isSale && product.salePrice != null) {
      return product.salePrice!;
    }
    return product.price;
  }

  void _decreaseStock(Product product, int quantity) {
    final newStock = product.stock - quantity;
    product.stock = newStock < 0 ? 0 : newStock;
  }

  // 장바구니 기반 주문 생성
  void placeOrderFromCart() {
    if (_cartWithQuantity.isEmpty) return;

    final items = _cartWithQuantity
        .map((item) => OrderItem(
              product: item.product,
              option: item.option,
              quantity: item.quantity,
              unitPrice: _getEffectivePrice(item.product),
            ))
        .toList();

    final total = items.fold<int>(
        0, (sum, item) => sum + item.unitPrice * item.quantity);

    for (final item in items) {
      _decreaseStock(item.product, item.quantity);
    }

    _orders.add(Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      totalAmount: total,
      date: DateTime.now(),
      status: '결제완료',
      statusLogs: [
        OrderStatusLog(status: '결제완료', date: DateTime.now()),
      ],
    ));

    _mileage += 500;
    clearCart();
    notifyListeners();
  }

  // 단일 상품 즉시구매
  void placeSingleOrder(Product product, {String? option}) {
    final items = [
      OrderItem(
        product: product,
        option: option,
        quantity: 1,
        unitPrice: _getEffectivePrice(product),
      ),
    ];

    final total = items.first.unitPrice;

    _decreaseStock(product, 1);

    _orders.add(Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      totalAmount: total,
      date: DateTime.now(),
      status: '결제완료',
      statusLogs: [
        OrderStatusLog(status: '결제완료', date: DateTime.now()),
      ],
    ));

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

  void advanceOrderStatus(String orderId) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    final currentIndex = _orderStatuses.indexOf(order.status);
    if (currentIndex >= 0 && currentIndex < _orderStatuses.length - 1) {
      final nextStatus = _orderStatuses[currentIndex + 1];
      order.status = nextStatus;
      order.statusLogs.add(OrderStatusLog(status: nextStatus, date: DateTime.now()));
      notifyListeners();
    }
  }

  void setOrderStatus(String orderId, String status) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    if (order.status != status) {
      order.status = status;
      order.statusLogs.add(OrderStatusLog(status: status, date: DateTime.now()));
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
