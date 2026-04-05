import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/firestore_paths.dart';
import 'product.dart';
import '../repositories/product_repository.dart';

// 사용자 화면 상태를 앱 전역에서 관리하는 클래스
// 필요한 데이터만 들고 있어 화면이 복잡해지지 않도록 중앙 관리한다.

enum UserRole { user, seller, admin }

class CartItem {
  final Product product;
  final String? option;
  int quantity;
  CartItem({required this.product, this.option, this.quantity = 1});
}

class Review {
  final String productId;
  final String productName;
  final double rating;
  final String comment;
  final DateTime date;
  final String? imagePath;

  Review({
    required this.productId,
    required this.productName,
    required this.rating,
    required this.comment,
    required this.date,
    this.imagePath,
  });
}

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
  final String paymentStatus;
  final bool agreementAccepted;
  final String? buyerId;
  final String? sellerId;
  final DateTime date;
  String status;
  String? trackingNumber;
  String? shippingMemo;
  DateTime? shippedAt;
  String? cancelReason;
  DateTime? canceledAt;
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
    this.buyerId,
    this.sellerId,
    required this.date,
    required this.status,
    this.trackingNumber,
    this.shippingMemo,
    this.shippedAt,
    this.cancelReason,
    this.canceledAt,
    required this.statusLogs,
  });
}

class OrderStatusLog {
  final String status;
  final DateTime date;
  final String actor;

  OrderStatusLog(
      {required this.status, required this.date, required this.actor});
}

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
  final String type;

  PaymentMethod({
    required this.id,
    required this.label,
    required this.type,
  });
}

class Coupon {
  final String id;
  final String title;
  final int discountAmount;
  final int minOrderAmount;
  final List<String> allowedCategories;
  final List<String> allowedProductIds;
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

class AdminUserSummary {
  final String id;
  final String email;
  final String userName;
  final UserRole role;

  AdminUserSummary({
    required this.id,
    required this.email,
    required this.userName,
    required this.role,
  });
}

class UserDataManager with ChangeNotifier {
  static const String _defaultSellerId = 'seller_demo';

  bool _isLoggedIn = false;
  String? _userId;
  UserRole _role = UserRole.user;
  String _userName = "손님";
  String _userEmail = '';
  int _mileage = 1500;
  int _reviewCount = 0;
  String? _backendError;
  bool _autoLoginEnabled = true;

  final bool _firebaseReady;
  FirebaseAuth? _auth;
  FirebaseFirestore? _db;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  UserRole get role => _role;
  bool get isAdmin => _role == UserRole.admin;
  bool get isSeller => _role == UserRole.seller || _role == UserRole.admin;
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get mileage => _mileage;
  int get reviewCount => _reviewCount;
  String? get backendError => _backendError;
  bool get autoLoginEnabled => _autoLoginEnabled;

  final List<Product> _products = [];
  List<Product> get products => _products;
  bool _productsLoading = false;
  bool _remoteProductsEnabled = false;
  bool get productsLoading => _productsLoading;
  bool get remoteProductsEnabled => _remoteProductsEnabled;

  final List<Address> _addresses = [
    Address(
      id: 'addr1',
      label: '집',
      recipient: '손님',
      addressLine: '서울시 강남구 테헤란로 123',
      phone: '010-1234-5678',
      requestNote: '문 앞에 놓아주세요',
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

  UserDataManager(
      {bool firebaseReady = false, bool remoteProductsEnabled = false})
      : _firebaseReady = firebaseReady,
        _remoteProductsEnabled = remoteProductsEnabled {
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
    reloadProducts();
    _restoreSession();
  }

  UserRole _roleFromEmail(String email) {
    final normalized = email.toLowerCase();
    if (normalized == 'admin@ceramic.com') return UserRole.admin;
    if (normalized == 'seller@ceramic.com') return UserRole.seller;
    return UserRole.user;
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.seller:
        return 'seller';
      case UserRole.user:
        return 'user';
    }
  }

  UserRole _roleFromString(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'seller':
        return UserRole.seller;
      default:
        return UserRole.user;
    }
  }

  Future<void> _persistOrder(Order order) async {
    if (!_firebaseReady || _db == null || _userId == null) return;
    try {
      final payload = _orderToMap(order);
      payload['buyerId'] = order.buyerId ?? _userId;
      payload['sellerId'] = order.sellerId ?? _defaultSellerId;
      payload['updatedAt'] = FieldValue.serverTimestamp();
      await _db!
          .collection(FirestorePaths.orders)
          .doc(order.id)
          .set(payload, SetOptions(merge: true));
      _backendError = null;
    } on FirebaseException catch (e) {
      _backendError = e.code;
    } catch (_) {
      _backendError = 'unknown';
    }
  }

  Future<void> _loadOrdersFromCollection() async {
    if (!_firebaseReady || _db == null || _userId == null) return;

    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (_role == UserRole.user) {
      snapshot = await _db!
          .collection(FirestorePaths.orders)
          .where('buyerId', isEqualTo: _userId)
          .get();
    } else if (_role == UserRole.seller) {
      final sellerIds = _currentSellerIdsForQuery();
      if (sellerIds.length == 1) {
        snapshot = await _db!
            .collection(FirestorePaths.orders)
            .where('sellerId', isEqualTo: sellerIds.first)
            .get();
      } else {
        snapshot = await _db!
            .collection(FirestorePaths.orders)
            .where('sellerId', whereIn: sellerIds)
            .get();
      }
    } else {
      snapshot = await _db!.collection(FirestorePaths.orders).get();
    }

    final loaded = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] ??= doc.id;
      return _orderFromMap(data);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    _orders
      ..clear()
      ..addAll(loaded);
  }

  List<String> _currentSellerIdsForQuery() {
    final userId = _userId;
    if (userId == null) return <String>[_defaultSellerId];
    final ids = <String>{userId};
    if (_userEmail.toLowerCase() == 'seller@ceramic.com') {
      // Backward compatibility for demo data created before sellerId migration.
      ids.add(_defaultSellerId);
    }
    return ids.toList();
  }

  String _resolveOrderSellerId(List<OrderItem> items) {
    for (final item in items) {
      final sellerId = item.product.sellerId;
      if (sellerId != null && sellerId.trim().isNotEmpty) {
        return sellerId;
      }
    }
    return _defaultSellerId;
  }

  Future<void> _migrateLegacyOrders(List<Order> legacyOrders) async {
    if (!_firebaseReady || _db == null || _userId == null) return;
    for (final order in legacyOrders) {
      final migrated = Order(
        id: order.id,
        items: order.items,
        totalAmount: order.totalAmount,
        discountAmount: order.discountAmount,
        mileageUsed: order.mileageUsed,
        couponTitle: order.couponTitle,
        addressSummary: order.addressSummary,
        paymentMethodLabel: order.paymentMethodLabel,
        paymentStatus: order.paymentStatus,
        agreementAccepted: order.agreementAccepted,
        buyerId: order.buyerId ?? _userId,
        sellerId: order.sellerId ?? _defaultSellerId,
        date: order.date,
        status: order.status,
        trackingNumber: order.trackingNumber,
        shippingMemo: order.shippingMemo,
        shippedAt: order.shippedAt,
        cancelReason: order.cancelReason,
        canceledAt: order.canceledAt,
        statusLogs: order.statusLogs,
      );
      await _persistOrder(migrated);
    }

    await _db!.collection(FirestorePaths.users).doc(_userId).set(
      {'orders': FieldValue.delete()},
      SetOptions(merge: true),
    );
  }

  Future<void> _restoreSession() async {
    if (!_firebaseReady || _auth == null) return;
    final prefs = await SharedPreferences.getInstance();
    _autoLoginEnabled = prefs.getBool('autoLoginEnabled') ?? true;
    if (!_autoLoginEnabled) {
      await _auth?.signOut();
      return;
    }
    final user = _auth!.currentUser;
    if (user == null) return;
    _isLoggedIn = true;
    _userId = user.uid;
    final email = user.email ?? '';
    _userEmail = email;
    _role = _roleFromEmail(email);
    await _loadFromBackend();
    notifyListeners();
  }

  ProductRepository _productRepository() {
    if (_remoteProductsEnabled && _firebaseReady && _db != null) {
      return FirestoreProductRepository(_db!);
    }
    return LocalProductRepository();
  }

  Future<void> reloadProducts() async {
    _productsLoading = true;
    notifyListeners();
    try {
      final items = await _productRepository().fetchProducts();
      _products
        ..clear()
        ..addAll(items);
    } catch (_) {
      if (_products.isEmpty) {
        _products.addAll(dummyProducts);
      }
    } finally {
      _productsLoading = false;
      notifyListeners();
    }
  }

  Future<void> setRemoteProductsEnabled(bool enabled) async {
    _remoteProductsEnabled = enabled;
    await reloadProducts();
  }

  Future<void> addProductBySeller({
    required String title,
    required String subTitle,
    required int price,
    required String category,
    required int stock,
    String? image,
    bool isNew = true,
    bool isSale = false,
    int? salePrice,
    List<String> options = const [],
  }) async {
    final sellerId = _userId ?? _defaultSellerId;
    final id = 'p_${DateTime.now().millisecondsSinceEpoch}';
    final product = Product(
      id: id,
      title: title,
      subTitle: subTitle,
      price: price,
      image: image,
      category: category,
      stock: stock,
      isNew: isNew,
      isSale: isSale,
      salePrice: salePrice,
      options: options,
      sellerId: sellerId,
    );

    _products.insert(0, product);
    notifyListeners();

    if (_remoteProductsEnabled && _firebaseReady && _db != null) {
      try {
        await _db!.collection(FirestorePaths.products).doc(id).set({
          'title': title,
          'subTitle': subTitle,
          'price': price,
          'image': image,
          'category': category,
          'stock': stock,
          'isNew': isNew,
          'isSale': isSale,
          'salePrice': salePrice,
          'options': options,
          'sellerId': sellerId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> updateProductBySeller(
    Product product, {
    required String title,
    required String subTitle,
    required int price,
    required String category,
    required int stock,
    String? image,
    bool? isNew,
    bool? isSale,
    int? salePrice,
    List<String>? options,
  }) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) return;

    final updated = Product(
      id: product.id,
      title: title,
      subTitle: subTitle,
      price: price,
      image: image,
      category: category,
      stock: stock,
      isNew: isNew ?? product.isNew,
      isSale: isSale ?? product.isSale,
      salePrice: salePrice,
      options: options ?? product.options,
      sellerId: product.sellerId ?? _userId ?? _defaultSellerId,
    );

    _products[index] = updated;
    notifyListeners();

    if (_remoteProductsEnabled && _firebaseReady && _db != null) {
      await _db!.collection(FirestorePaths.products).doc(product.id).set({
        'title': title,
        'subTitle': subTitle,
        'price': price,
        'image': image,
        'category': category,
        'stock': stock,
        'isNew': isNew ?? product.isNew,
        'isSale': isSale ?? product.isSale,
        'salePrice': salePrice,
        'options': options ?? product.options,
        'sellerId': product.sellerId ?? _userId ?? _defaultSellerId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> deleteProductBySeller(Product product) async {
    _products.removeWhere((p) => p.id == product.id);
    _wishlist.removeWhere((p) => p.id == product.id);
    _cartWithQuantity.removeWhere((item) => item.product.id == product.id);
    notifyListeners();

    if (_remoteProductsEnabled && _firebaseReady && _db != null) {
      await _db!.collection(FirestorePaths.products).doc(product.id).delete();
    }
  }

  List<Address> get addresses => _addresses;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<Coupon> get coupons => _coupons;
  int get availableCouponCount => _coupons.where((c) => !c.isUsed).length;
  int get totalCouponCount => _coupons.length;

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

  void addAddress(Address address) {
    _addresses.add(address);
    _selectedAddressId = address.id;
    _persist();
    notifyListeners();
  }

  void updateAddress(Address updated) {
    final index = _addresses.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _addresses[index] = updated;
      _persist();
      notifyListeners();
    }
  }

  void setDefaultAddress(String id) {
    if (_addresses.any((a) => a.id == id)) {
      _selectedAddressId = id;
      _persist();
      notifyListeners();
    }
  }

  void addPaymentMethod(PaymentMethod method) {
    _paymentMethods.add(method);
    _selectedPaymentId = method.id;
    _persist();
    notifyListeners();
  }

  void updatePaymentMethod(PaymentMethod method) {
    final index = _paymentMethods.indexWhere((p) => p.id == method.id);
    if (index != -1) {
      _paymentMethods[index] = method;
      _persist();
      notifyListeners();
    }
  }

  void setDefaultPayment(String id) {
    if (_paymentMethods.any((p) => p.id == id)) {
      _selectedPaymentId = id;
      _persist();
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!_firebaseReady) {
      _isLoggedIn = true;
      _userId = email;
      _userName = name;
      _userEmail = email;
      _role = _roleFromEmail(email);
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
    _userEmail = email;
    _role = _roleFromEmail(email);
    try {
      await _persist();
    } catch (_) {
      // 네트워크/Firestore 오류가 있어도 로그인/회원가입 자체는 유지한다.
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    if (!_firebaseReady) {
      _isLoggedIn = true;
      _userId = email;
      _userEmail = email;
      _role = _roleFromEmail(email);
      notifyListeners();
      return;
    }

    await _auth!.signInWithEmailAndPassword(email: email, password: password);

    _isLoggedIn = true;
    _userId = _auth!.currentUser?.uid;
    _userEmail = email;
    _role = _roleFromEmail(email);
    try {
      await _loadFromBackend();
      await _persist();
    } catch (_) {
      // Firestore 오프라인 등으로 실패해도 로그인은 성공 처리
    }
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userId = null;
    _role = UserRole.user;
    _userName = "손님";
    _userEmail = '';
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

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;
  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  final List<Order> _orders = [];
  List<Order> get orders => _orders;

  List<Product> get purchasedProducts {
    final Map<String, Product> map = {};
    for (final order in _orders) {
      for (final item in order.items) {
        map[item.product.id] = item.product;
      }
    }
    return map.values.toList();
  }

  final List<Product> _wishlist = [];
  List<Product> get wishlist => _wishlist;

  void toggleWishlist(Product product) {
    _wishlist.contains(product)
        ? _wishlist.remove(product)
        : _wishlist.add(product);
    _persist();
    notifyListeners();
  }

  bool isFavorite(Product product) => _wishlist.contains(product);

  final List<CartItem> _cartWithQuantity = [];
  List<CartItem> get items => _cartWithQuantity;

  void addToCart(Product product, {String? selectedOption}) {
    if (product.stock == 0) return;
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

  void addToCartMultiple(Product product, int quantity,
      {String? selectedOption}) {
    if (quantity <= 0) return;
    for (int i = 0; i < quantity; i++) {
      addToCart(product, selectedOption: selectedOption);
    }
  }

  void removeFromCart(Product product, {String? option}) {
    _cartWithQuantity.removeWhere(
        (item) => item.product.id == product.id && item.option == option);
    _persist();
    notifyListeners();
  }

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

  int _getEffectivePrice(Product product) {
    if (product.isSale && product.salePrice != null) {
      return product.salePrice!;
    }
    return product.price;
  }

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

  int _calculateMileageUsage(int requested, int subtotalAfterCoupon) {
    final maxUsable =
        _mileage < subtotalAfterCoupon ? _mileage : subtotalAfterCoupon;
    return requested > maxUsable ? maxUsable : requested;
  }

  void _decreaseStock(Product product, int quantity) {
    final newStock = product.stock - quantity;
    product.stock = newStock < 0 ? 0 : newStock;
  }

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

    final createdOrder = Order(
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
      buyerId: _userId,
      sellerId: _resolveOrderSellerId(items),
      date: DateTime.now(),
      status: '결제완료',
      statusLogs: [
        OrderStatusLog(
            status: '결제완료', date: DateTime.now(), actor: '시스템'),
      ],
    );
    _orders.add(createdOrder);
    _persistOrder(createdOrder);

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

  void placeSingleOrder(Product product,
      {String? option,
      int quantity = 1,
      String? couponId,
      int mileageUsed = 0,
      Address? address,
      PaymentMethod? payment,
      bool agreementAccepted = false}) {
    final items = [
      OrderItem(
        product: product,
        option: option,
        quantity: quantity,
        unitPrice: _getEffectivePrice(product),
      ),
    ];

    final subtotal = items.first.unitPrice * quantity;
    final coupon = couponId == null
        ? null
        : _coupons.firstWhere((c) => c.id == couponId,
            orElse: () => _coupons.first);
    final couponDiscount = _calculateCouponDiscount(coupon, subtotal, items);
    final mileageToUse =
        _calculateMileageUsage(mileageUsed, subtotal - couponDiscount);
    final total = subtotal - couponDiscount - mileageToUse;

    _decreaseStock(product, quantity);

    final createdOrder = Order(
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
      buyerId: _userId,
      sellerId: _resolveOrderSellerId(items),
      date: DateTime.now(),
      status: '결제완료',
      statusLogs: [
        OrderStatusLog(
            status: '결제완료', date: DateTime.now(), actor: '시스템'),
      ],
    );
    _orders.add(createdOrder);
    _persistOrder(createdOrder);

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

  static const List<String> _orderStatuses = [
    '결제완료',
    '배송준비',
    '배송중',
    '배송완료',
    '취소요청',
    '취소완료',
  ];

  void advanceOrderStatus(String orderId, {String actor = '관리자'}) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    final currentIndex = _orderStatuses.indexOf(order.status);
    if (currentIndex >= 0 && currentIndex < _orderStatuses.length - 1) {
      final nextStatus = _orderStatuses[currentIndex + 1];
      order.status = nextStatus;
      order.statusLogs.add(
          OrderStatusLog(status: nextStatus, date: DateTime.now(), actor: actor));
      _persistOrder(order);
      _persist();
      notifyListeners();
    }
  }

  void setOrderStatus(String orderId, String status, {String actor = '관리자'}) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    if (order.status != status) {
      order.status = status;
      if (status == '배송중') {
        order.shippedAt ??= DateTime.now();
      }
      if (status == '취소완료') {
        order.canceledAt = DateTime.now();
      }
      order.statusLogs.add(
          OrderStatusLog(status: status, date: DateTime.now(), actor: actor));
      _persistOrder(order);
      _persist();
      notifyListeners();
    }
  }

  bool canRequestCancellation(Order order) {
    return order.status == '결제완료' || order.status == '배송준비';
  }

  void requestOrderCancellation(
    String orderId, {
    String? reason,
    String actor = '구매자',
  }) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    if (!canRequestCancellation(order)) return;

    final normalizedReason = (reason ?? '').trim();
    if (normalizedReason.isNotEmpty) {
      order.cancelReason = normalizedReason;
    }
    order.status = '취소요청';
    order.statusLogs.add(
      OrderStatusLog(status: '취소요청', date: DateTime.now(), actor: actor),
    );
    _persistOrder(order);
    _persist();
    notifyListeners();
  }

  void markOrderShipped(
    String orderId, {
    required String trackingNumber,
    String? shippingMemo,
    String actor = '판매자',
  }) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    order.trackingNumber = trackingNumber.trim();
    final memo = (shippingMemo ?? '').trim();
    order.shippingMemo = memo.isEmpty ? null : memo;
    order.shippedAt = DateTime.now();
    order.status = '배송중';
    order.statusLogs.add(
      OrderStatusLog(status: '배송중', date: DateTime.now(), actor: actor),
    );
    _persistOrder(order);
    _persist();
    notifyListeners();
  }

  void markOrderCanceled(
    String orderId, {
    required String reason,
    String actor = '판매자',
  }) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    final normalizedReason = reason.trim();
    order.cancelReason = normalizedReason.isEmpty ? '판매자 취소 처리' : normalizedReason;
    order.canceledAt = DateTime.now();
    order.status = '취소완료';
    order.statusLogs.add(
      OrderStatusLog(status: '취소완료', date: DateTime.now(), actor: actor),
    );
    _persistOrder(order);
    _persist();
    notifyListeners();
  }

  final List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  void removeReviewAt(int index) {
    _reviews.removeAt(index);
    _reviewCount = _reviews.length;
    _persist();
    notifyListeners();
  }

  bool hasReview(String productId) {
    return _reviews.any((r) => r.productId == productId);
  }

  Review? getReview(String productId) {
    try {
      return _reviews.firstWhere((r) => r.productId == productId);
    } catch (e) {
      return null;
    }
  }

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

  void addReview(
      String productId, String productName, double rating, String comment,
      {String? imagePath}) {
    _reviews.add(Review(
      productId: productId,
      productName: productName,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
      imagePath: imagePath,
    ));

    _mileage += 100;
    _reviewCount = _reviews.length;
    _persist();
    notifyListeners();
  }

  void updateReview(
      String productId, double rating, String comment, String? imagePath) {
    final index = _reviews.indexWhere((r) => r.productId == productId);
    if (index != -1) {
      _reviews[index] = Review(
        productId: productId,
        productName: _reviews[index].productName,
        rating: rating,
        comment: comment,
        date: DateTime.now(),
        imagePath: imagePath,
      );
      _persist();
      notifyListeners();
    }
  }

  Future<void> _loadFromBackend() async {
    if (!_firebaseReady || _userId == null) return;
    try {
      final doc = await _db!.collection('users').doc(_userId).get();
      if (!doc.exists) {
        _backendError = null;
        return;
      }
      final data = doc.data()!;
      _userName = data['userName'] ?? _userName;
      _userEmail = data['email'] ?? _userEmail;
      _mileage = data['mileage'] ?? _mileage;
      final roleStr = data['role'] as String? ?? 'user';
      _role = _roleFromString(roleStr);

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
      await _loadOrdersFromCollection();

      if (_orders.isEmpty && (data['orders'] as List<dynamic>? ?? []).isNotEmpty) {
        final legacyOrders = (data['orders'] as List<dynamic>)
            .map((e) => _orderFromMap(Map<String, dynamic>.from(e)))
            .toList();
        await _migrateLegacyOrders(legacyOrders);
        await _loadOrdersFromCollection();
      }

      final usedCoupons = (data['usedCoupons'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toSet();
      for (final c in _coupons) {
        c.isUsed = usedCoupons.contains(c.id);
      }
      _reviewCount = _reviews.length;
      _backendError = null;
    } on FirebaseException catch (e) {
      _backendError = e.code;
    } catch (_) {
      _backendError = 'unknown';
    }
  }

  Future<void> _persist() async {
    if (!_firebaseReady || _userId == null) return;
    final data = {
      'userName': _userName,
      'email': _userEmail,
      'mileage': _mileage,
      'reviewCount': _reviews.length,
      'role': _roleToString(_role),
      'addresses': _addresses.map(_addressToMap).toList(),
      'paymentMethods': _paymentMethods.map(_paymentToMap).toList(),
      'reviews': _reviews.map(_reviewToMap).toList(),
      'usedCoupons': _coupons.where((c) => c.isUsed).map((c) => c.id).toList(),
    };
    try {
      await _db!
          .collection('users')
          .doc(_userId)
          .set(data, SetOptions(merge: true));
      _backendError = null;
    } on FirebaseException catch (e) {
      _backendError = e.code;
    } catch (_) {
      _backendError = 'unknown';
    }
  }

  Future<List<AdminUserSummary>> loadUsersForAdmin() async {
    if (!_firebaseReady || _db == null || !isAdmin) return [];
    final snapshot = await _db!.collection(FirestorePaths.users).get();
    final users = snapshot.docs.map((doc) {
      final data = doc.data();
      final role = _roleFromString(data['role'] as String?);
      return AdminUserSummary(
        id: doc.id,
        email: (data['email'] as String?) ?? '',
        userName: (data['userName'] as String?) ?? '사용자',
        role: role,
      );
    }).toList()
      ..sort((a, b) => a.userName.compareTo(b.userName));
    return users;
  }

  Future<void> updateUserRoleByAdmin({
    required String targetUserId,
    required UserRole role,
  }) async {
    if (!_firebaseReady || _db == null || !isAdmin) return;
    await _db!.collection(FirestorePaths.users).doc(targetUserId).set(
      {'role': _roleToString(role)},
      SetOptions(merge: true),
    );
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
        'buyerId': o.buyerId,
        'sellerId': o.sellerId,
        'date': o.date.toIso8601String(),
        'status': o.status,
        'trackingNumber': o.trackingNumber,
        'shippingMemo': o.shippingMemo,
        'shippedAt': o.shippedAt?.toIso8601String(),
        'cancelReason': o.cancelReason,
        'canceledAt': o.canceledAt?.toIso8601String(),
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
        buyerId: m['buyerId'],
        sellerId: m['sellerId'],
        date: DateTime.parse(m['date']),
        status: m['status'],
        trackingNumber: m['trackingNumber'],
        shippingMemo: m['shippingMemo'],
        shippedAt: (m['shippedAt'] is String && (m['shippedAt'] as String).isNotEmpty)
            ? DateTime.parse(m['shippedAt'])
            : null,
        cancelReason: m['cancelReason'],
        canceledAt:
            (m['canceledAt'] is String && (m['canceledAt'] as String).isNotEmpty)
                ? DateTime.parse(m['canceledAt'])
                : null,
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
        'sellerId': p.sellerId,
      };

  Product _productFromMap(Map<String, dynamic> m) => Product(
        id: m['id'],
        title: m['title'],
        subTitle: m['subTitle'],
        price: m['price'],
        image: m['image'],
        category: m['category'],
        salePrice: m['salePrice'],
        sellerId: m['sellerId'],
      );
}
