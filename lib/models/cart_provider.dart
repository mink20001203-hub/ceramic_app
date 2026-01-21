import 'package:flutter/material.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // 장바구니 담기 (이미 있으면 수량 증가)
  void addToCart(Product product) {
    for (var item in _items) {
      if (item.product.id == product.id) {
        item.quantity++;
        notifyListeners();
        return;
      }
    }
    _items.add(CartItem(product: product));
    notifyListeners();
  }

  // 수량 하나 감소 (3단계에서 발생한 에러 해결 부분)
  void removeSingleItem(String productId) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].product.id == productId) {
        if (_items[i].quantity > 1) {
          _items[i].quantity--;
        } else {
          _items.removeAt(i);
        }
        break;
      }
    }
    notifyListeners();
  }

  // 해당 상품 전체 삭제
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // 장바구니 비우기
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // 총액 계산
  int get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.product.price * item.quantity;
    }
    return total.toInt();
  }
}
