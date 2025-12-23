import 'package:flutter/material.dart';
import 'product.dart';

class UserDataManager with ChangeNotifier {
  // 1. 하단 탭 바 인덱스 관리
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // 2. 마일리지 및 후기 정보
  int _mileage = 1500;
  int get mileage => _mileage;

  int _reviewCount = 2;
  int get reviewCount => _reviewCount;

  // 3. 구매 기록 관리
  final List<Product> _purchasedProducts = [];
  List<Product> get purchasedProducts => _purchasedProducts;

  void addPurchase(List<Product> products) {
    _purchasedProducts.addAll(products);
    _mileage += 500;
    notifyListeners();
  }

  // 4. 찜하기(위시리스트) 기능
  final List<Product> _wishlist = [];
  List<Product> get wishlist => _wishlist;

  void toggleWishlist(Product product) {
    if (_wishlist.contains(product)) {
      _wishlist.remove(product);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  bool isFavorite(Product product) {
    return _wishlist.contains(product);
  }

  // ✅ 5. 장바구니 기능 (클래스 안에 정확히 포함됨)
  final List<Product> _cartItems = [];
  List<Product> get cartItems => _cartItems;

  void addToCart(Product product) {
    if (!_cartItems.contains(product)) {
      _cartItems.add(product);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
} // <--- 클래스를 닫는 이 중괄호가 맨 마지막에 와야 합니다!
