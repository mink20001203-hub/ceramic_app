import 'package:flutter/material.dart';
import 'product.dart';

// --- 1. 장바구니 아이템 모델 (기존 유지) ---
class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
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

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
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
    _currentTabIndex = index;
    notifyListeners();
  }

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

  // --- 장바구니 로직 (기존 유지) ---
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

  void removeFromCart(Product product) {
    _cartWithQuantity.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    for (var item in _cartWithQuantity) {
      if (item.product.id == productId) {
        item.quantity++;
        notifyListeners();
        return;
      }
    }
  }

  void decrementQuantity(String productId) {
    for (var item in _cartWithQuantity) {
      if (item.product.id == productId && item.quantity > 1) {
        item.quantity--;
        notifyListeners();
        return;
      }
    }
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
