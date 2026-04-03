import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';

class SellerOrderDetailScreen extends StatelessWidget {
  final String orderId;

  const SellerOrderDetailScreen({super.key, required this.orderId});

  static const List<String> _statusOptions = [
    '결제완료',
    '배송준비',
    '배송중',
    '배송완료',
  ];

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###', 'ko_KR');

    return Consumer<UserDataManager>(
      builder: (context, manager, _) {
        final order = manager.orders.firstWhere((o) => o.id == orderId);
        return Scaffold(
          appBar: AppBar(title: const Text('주문 상세')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              OudSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '주문번호 ${order.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('yyyy.MM.dd HH:mm').format(order.date),
                      style: const TextStyle(color: OudColors.mutedText),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: order.status,
                      decoration: const InputDecoration(labelText: '주문 상태'),
                      items: _statusOptions
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        manager.setOrderStatus(order.id, value, actor: '판매자');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OudSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '배송 정보',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.addressSummary,
                      style: const TextStyle(color: OudColors.mutedText),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '결제 정보',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '결제수단: ${order.paymentMethodLabel}',
                      style: const TextStyle(color: OudColors.mutedText),
                    ),
                    Text(
                      '결제상태: ${order.paymentStatus}',
                      style: const TextStyle(color: OudColors.mutedText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OudSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '상태 로그',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    ...order.statusLogs.map(
                      (log) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${DateFormat('MM.dd HH:mm').format(log.date)} · ${log.status} · ${log.actor}',
                          style: const TextStyle(color: OudColors.mutedText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OudSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '주문 상품',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.title} (${item.option ?? '기본'}) x${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '₩${format.format(item.unitPrice * item.quantity)}',
                              style: const TextStyle(
                                color: OudColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Text(
                          '최종 결제금액',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text(
                          '₩${format.format(order.totalAmount)}',
                          style: const TextStyle(
                            color: OudColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ],
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
