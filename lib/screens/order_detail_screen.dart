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
        final isAdmin = manager.isLoggedIn && manager.userName == '관리자';

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
                    '${DateFormat('MM.dd HH:mm').format(log.date)} · ${log.status}',
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
                          ? () => manager.advanceOrderStatus(order.id)
                          : null,
                      child: const Text('다음 상태로 변경(관리자)'),
                    ),
                  ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
