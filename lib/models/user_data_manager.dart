import 'package:flutter/material.dart';
import 'product.dart';

// --- 1. 장바구니 아이템 모델 ---
class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

// --- 2. 리뷰 데이터 모델 ---
class Review {
  final String productId;
  final String productName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.productId,
    required this.productName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

// --- 3. 통합 데이터 관리 클래스 ---
class UserDataManager with ChangeNotifier {
  // ✅ [로그인 및 사용자 정보 관리]
  bool _isLoggedIn = false;
  String _userName = "손님"; // 사용자 이름 추가 (기본값: 손님)

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName; // 외부에서 이름을 읽기 위한 Getter

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = "손님"; // 로그아웃 시 이름 초기화
    notifyListeners();
  }

  // ✅ 회원가입 시 이름을 저장하기 위한 함수
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  // --- 기존 로직들 유지 ---

  // 탭 관리
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;
  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // 프로필 정보 (마일리지, 후기 수)
  int _mileage = 1500;
  int get mileage => _mileage;
  int _reviewCount = 2;
  int get reviewCount => _reviewCount;

  // 구매 목록
  final List<Product> _purchasedProducts = [];
  List<Product> get purchasedProducts => _purchasedProducts;

  void addPurchase(List<Product> products) {
    _purchasedProducts.addAll(products);
    _mileage += 500;
    notifyListeners();
  }

  // 찜하기(위시리스트)
  final List<Product> _wishlist = [];
  List<Product> get wishlist => _wishlist;

  void toggleWishlist(Product product) {
    _wishlist.contains(product)
        ? _wishlist.remove(product)
        : _wishlist.add(product);
    notifyListeners();
  }

  bool isFavorite(Product product) => _wishlist.contains(product);

  // 장바구니 로직
  final List<CartItem> _cartWithQuantity = [];
  List<CartItem> get items => _cartWithQuantity;

  void addToCart(Product product) {
    for (var item in _cartWithQuantity) {
      if (item.product.id == product.id) {
        item.quantity++;
        notifyListeners();
        return;
      }
    }
    _cartWithQuantity.add(CartItem(product: product));
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    _cartWithQuantity.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartWithQuantity.clear();
    notifyListeners();
  }

  int get totalAmount {
    int total = 0;
    for (var item in _cartWithQuantity) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  // 리뷰 로직
  final List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  void addReview(
      String productId, String productName, double rating, String comment) {
    _reviews.add(Review(
      productId: productId,
      productName: productName,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    ));

    _mileage += 100; // 리뷰 보너스 마일리지
    _reviewCount++; // 프로필 후기 개수 증가

    notifyListeners();
  }
}
