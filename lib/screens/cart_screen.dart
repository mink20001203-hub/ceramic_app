import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    // ✅ Consumer를 사용하여 UserDataManager의 상태 변화를 감시합니다.
    return Consumer<UserDataManager>(
      builder: (context, userManager, child) {
        // UserDataManager 안에 있는 items(장바구니 리스트)를 가져옵니다.
        final cartItems = userManager.items;

        return Scaffold(
          appBar: AppBar(
            title: const Text('내 장바구니'),
            centerTitle: true,
            elevation: 0,
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
                            child: ListTile(
                              leading: Image.asset(
                                item.product.image!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(item.product.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${priceFormat.format(item.product.price)}원 x ${item.quantity}개'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  // 상품 한 종류 삭제 로직
                                  userManager.removeSingleItem(item.product.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // 하단 합계 및 주문하기 버튼 영역
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
                                      // 1. 현재 장바구니 상품들을 구매 목록으로 전달
                                      final productsToBuy = cartItems
                                          .map((e) => e.product)
                                          .toList();
                                      userManager.addPurchase(productsToBuy);

                                      // 2. 장바구니 비우기
                                      userManager.clearCart();

                                      // 3. 알림 메시지 표시
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                '주문이 완료되었습니다! 마이페이지로 이동합니다.')),
                                      );

                                      // 4. 마이페이지 탭(index 3)으로 이동
                                      userManager.setTabIndex(3);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
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
