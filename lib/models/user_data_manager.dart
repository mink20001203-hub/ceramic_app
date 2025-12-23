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
    _mileage += 500; // 주문 시 마일리지 적립
    notifyListeners();
  }

  // 4. ✅ 찜하기(위시리스트) 기능 추가
  final List<Product> _wishlist = [];
  List<Product> get wishlist => _wishlist;

  // 찜 상태 토글 (있으면 삭제, 없으면 추가)
  void toggleWishlist(Product product) {
    if (_wishlist.contains(product)) {
      _wishlist.remove(product);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  // 현재 상품이 찜 상태인지 확인
  bool isFavorite(Product product) {
    return _wishlist.contains(product);
  }
}
