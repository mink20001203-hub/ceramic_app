import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/cart_provider.dart';
import '../models/user_data_manager.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final NumberFormat priceFormat = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('장바구니'),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('장바구니가 비어 있습니다.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items[i];
                      return ListTile(
                        leading: item.product.image != null
                            ? Image.asset(item.product.image!,
                                width: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image),
                        title: Text(item.product.title),
                        subtitle: Text(
                            '${priceFormat.format(item.product.price)}원 x ${item.quantity}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            cart.removeItem(item.product.id);
                          },
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
                          offset: const Offset(0, -5))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('총 결제 금액',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${priceFormat.format(cart.totalAmount)}원',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6750A4))),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          if (cart.items.isEmpty) return;

                          // 1. 주문 데이터를 UserDataManager에 추가
                          final userManager = Provider.of<UserDataManager>(
                              context,
                              listen: false);

                          for (var cartItem in cart.items) {
                            userManager.addPurchase(
                              PurchaseRecord(
                                title: cartItem.product.title,
                                price:
                                    cartItem.product.price * cartItem.quantity,
                                date: DateTime.now(),
                              ),
                            );
                          }

                          // 2. 장바구니 비우기
                          cart.clearCart();

                          // 3. 완료 다이얼로그
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('주문 완료'),
                              content: const Text(
                                  '성공적으로 주문되었습니다!\n마이페이지에서 내역을 확인하세요.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6750A4),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('주문하기',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
