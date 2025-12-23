import 'package:flutter/material.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class UserDataManager with ChangeNotifier {
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  int _mileage = 1500;
  int get mileage => _mileage;

  int _reviewCount = 2;
  int get reviewCount => _reviewCount;

  final List<Product> _purchasedProducts = [];
  List<Product> get purchasedProducts => _purchasedProducts;

  void addPurchase(List<Product> products) {
    _purchasedProducts.addAll(products);
    _mileage += 500;
    notifyListeners();
  }

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

  // ✅ 요청하신 총액 계산 로직
  int get totalAmount {
    int total = 0;
    for (var item in _cartWithQuantity) {
      total += item.product.price * item.quantity;
    }
    return total;
  }
}
