import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import 'order_detail_screen.dart';

class UserOrderListScreen extends StatelessWidget {
  const UserOrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final orders = List<Order>.from(manager.orders)..sort((a, b) => b.date.compareTo(a.date));
    final format = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 및 배송 조회'),
        centerTitle: true,
      ),
      body: OudFadeSwitcher(
        child: orders.isEmpty
            ? const OudEmptyState(
                key: ValueKey('order-empty'),
                title: '주문 내역이 없습니다',
                subtitle: '상품을 주문하면 이 화면에서 상태를 확인할 수 있습니다.',
                icon: Icons.receipt_long_outlined,
              )
            : ListView.builder(
                key: const ValueKey('order-list'),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                itemCount: orders.length,
                itemBuilder: (_, index) {
                  final order = orders[index];
                  final dateLabel = DateFormat('yyyy.MM.dd HH:mm').format(order.date);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: OudRadii.lg,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
                        );
                      },
                      child: OudSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '주문번호 ${order.id}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                  ),
                                ),
                                _statusPill(order.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(dateLabel, style: const TextStyle(color: OudColors.mutedText)),
                            const SizedBox(height: 8),
                            Text(
                              order.items.first.product.title,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            if (order.items.length > 1)
                              Text(
                                '외 ${order.items.length - 1}개 상품',
                                style: const TextStyle(color: OudColors.mutedText),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '₩${format.format(order.totalAmount)}',
                                  style: const TextStyle(
                                    color: OudColors.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 19,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  '상세보기',
                                  style: TextStyle(color: OudColors.mutedText, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _statusPill(String status) {
    final isCancel = status.contains('취소');
    final bg = isCancel ? const Color(0xFFF6DDDA) : OudColors.surface;
    final fg = isCancel ? const Color(0xFF9D4A3E) : OudColors.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: OudRadii.pill),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
