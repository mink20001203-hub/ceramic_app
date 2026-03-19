import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

// 장바구니 화면: 수량 변경 및 주문 확인까지 처리한다.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    void _showOrderConfirmDialog(
        BuildContext context, UserDataManager userManager) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('주문 확인'),
            content: Text(
              '총 ${userManager.items.length}개의 상품을 주문하시겠습니까?\n'
              '결제 금액: ${NumberFormat('#,###', 'ko_KR').format(userManager.totalAmount)}원',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!userManager.isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인 후 결제할 수 있습니다.')),
                    );
                    return;
                  }
                  final hasSoldOut = userManager.items
                      .any((item) => item.product.stock == 0);
                  final overStock = userManager.items.any(
                      (item) => item.quantity > item.product.stock);
                  if (hasSoldOut || overStock) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('재고를 확인해 주세요. 품절/수량 초과 항목이 있습니다.')),
                    );
                    return;
                  }

                  Navigator.of(context).pop();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckoutScreen.cart(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
                child:
                    const Text('주문하기', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }

    return Consumer<UserDataManager>(
      builder: (context, userManager, child) {
        final cartItems = userManager.items;
        for (final item in cartItems) {
          if (item.product.stock == 0) continue;
          if (item.quantity > item.product.stock) {
            item.quantity = item.product.stock;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('장바구니'),
            centerTitle: true,
            elevation: 0,
            actions: [
              if (cartItems.isNotEmpty)
                TextButton(
                  onPressed: () => userManager.clearCart(),
                  child:
                      const Text('전체 삭제', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
          body: cartItems.isEmpty
              ? const Center(
                  child: Text(
                    '장바구니가 비어 있습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: item.product.image != null
                                    ? Image.asset(
                                        item.product.image!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                            Icons.image_not_supported),
                                      ),
                                title: Text(item.product.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.product.stock == 0)
                                      const Text('품절',
                                          style: TextStyle(color: Colors.red)),
                                    if (item.product.stock > 0 &&
                                        item.quantity > item.product.stock)
                                      const Text('재고 부족',
                                          style: TextStyle(color: Colors.red)),
                                    if (item.option != null)
                                      Text('옵션: ${item.option}'),
                                    Text(
                                      '${priceFormat.format(((item.product.isSale && item.product.salePrice != null) ? item.product.salePrice! : item.product.price) * item.quantity)}원',
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () => userManager
                                          .decrementQuantity(
                                              item.product.id, item.option),
                                    ),
                                    Text('${item.quantity}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      onPressed: () => userManager
                                          .incrementQuantity(
                                              item.product.id, item.option),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.grey),
                                      onPressed: () => userManager
                                          .removeSingleItem(
                                              item.product.id, item.option),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('총 결제 금액',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '${priceFormat.format(userManager.totalAmount)}원',
                                style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: cartItems.isEmpty
                                  ? null
                                  : () => _showOrderConfirmDialog(
                                      context, userManager),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('주문하기',
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
