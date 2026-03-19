import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';

// 주문 상세 화면: 주문 상태 로그와 주문 상품 목록을 보여준다.
class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    return Consumer<UserDataManager>(
      builder: (context, manager, child) {
        final order = manager.orders.firstWhere((o) => o.id == orderId);
        final isAdmin = manager.isLoggedIn && manager.isAdmin;

        return Scaffold(
          appBar: AppBar(
            title: const Text('주문 상세'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('주문번호 ${order.id}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  '${DateFormat('yyyy.MM.dd').format(order.date)} · ${order.status}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text('상태 로그',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ...order.statusLogs.map(
                  (log) => Text(
                    '${DateFormat('MM.dd HH:mm').format(log.date)} · ${log.status} · ${log.actor}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                if (order.status != '배송완료')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      // 관리자만 주문 상태 변경 가능
                      onPressed: isAdmin
                          ? () => manager.advanceOrderStatus(order.id,
                              actor: '관리자')
                          : null,
                      child: const Text('다음 상태로 변경(관리자)'),
                    ),
                  ),
                const Divider(),
                const Text('배송/결제 정보',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(order.addressSummary,
                    style: const TextStyle(color: Colors.grey)),
                Text('결제수단: ${order.paymentMethodLabel}',
                    style: const TextStyle(color: Colors.grey)),
                Text('결제상태: ${order.paymentStatus}',
                    style: const TextStyle(color: Colors.grey)),
                const Divider(),
                const Text('주문 상품',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.product.title),
                      subtitle: Text(
                          '옵션: ${item.option ?? '기본'} · 수량: ${item.quantity}'),
                      trailing: Text(
                        '${priceFormat.format(item.unitPrice * item.quantity)}원',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('총 결제금액',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${priceFormat.format(order.totalAmount)}원',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6342E8))),
                  ],
                ),
                if (order.discountAmount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('할인: -${priceFormat.format(order.discountAmount)}원',
                        style: const TextStyle(color: Colors.grey)),
                  ),
                if (order.couponTitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('쿠폰: ${order.couponTitle}',
                        style: const TextStyle(color: Colors.grey)),
                  ),
                if (order.mileageUsed > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('마일리지 사용: ${order.mileageUsed}P',
                        style: const TextStyle(color: Colors.grey)),
                  ),
                const SizedBox(height: 8),
                const Text('혜택 이력',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  order.couponTitle != null
                      ? '쿠폰 적용: ${order.couponTitle}'
                      : '쿠폰 적용 없음',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  order.mileageUsed > 0
                      ? '마일리지 사용: ${order.mileageUsed}P'
                      : '마일리지 사용 없음',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // 주문 상품을 장바구니에 다시 담는다.
                    onPressed: () {
                      int added = 0;
                      int skipped = 0;
                      for (final item in order.items) {
                        if (item.product.stock == 0) {
                          skipped += item.quantity;
                          continue;
                        }
                        final addQty = item.quantity > item.product.stock
                            ? item.product.stock
                            : item.quantity;
                        for (int i = 0; i < addQty; i++) {
                          manager.addToCart(item.product,
                              selectedOption: item.option);
                        }
                        added += addQty;
                        if (addQty < item.quantity) {
                          skipped += (item.quantity - addQty);
                        }
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(added == 0
                                ? '품절로 장바구니에 담을 수 없습니다.'
                                : (skipped > 0
                                    ? '재고 부족으로 일부만 담았습니다.'
                                    : '장바구니에 담았습니다.'))),
                      );
                    },
                    child: const Text('재주문(장바구니 담기)'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
