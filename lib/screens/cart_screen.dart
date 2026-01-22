import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    return Consumer<UserDataManager>(
      builder: (context, userManager, child) {
        final cartItems = userManager.items;

        return Scaffold(
          appBar: AppBar(
            title: const Text('내 장바구니'),
            centerTitle: true,
            elevation: 0,
            actions: [
              if (cartItems.isNotEmpty)
                TextButton(
                  onPressed: () => userManager.clearCart(),
                  child:
                      const Text('전체삭제', style: TextStyle(color: Colors.red)),
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
                                leading: Image.asset(
                                  item.product.image!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(item.product.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${priceFormat.format(item.product.price * item.quantity)}원'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () => userManager
                                          .decrementQuantity(item.product.id),
                                    ),
                                    Text('${item.quantity}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      onPressed: () => userManager
                                          .incrementQuantity(item.product.id),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.grey),
                                      onPressed: () => userManager
                                          .removeSingleItem(item.product.id),
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
                                  : () {
                                      final productsToBuy = cartItems
                                          .map((e) => e.product)
                                          .toList();
                                      userManager.addPurchase(productsToBuy);
                                      userManager.clearCart();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('주문이 완료되었습니다!')),
                                      );
                                      userManager.setTabIndex(3);
                                    },
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
