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
            : ListView(
                key: const ValueKey('order-list'),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                children: [
                  const _OrderConfidenceBanner(),
                  const SizedBox(height: 10),
                  ...orders.map((order) {
                    final dateLabel = DateFormat('yyyy.MM.dd HH:mm').format(order.date);
                    final canCancel = order.status == '결제완료' || order.status == '배송준비';
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
                              const SizedBox(height: 6),
                              Text(
                                canCancel
                                    ? '취소 가능 상태입니다. 상세에서 즉시 취소요청할 수 있습니다.'
                                    : '배송 단계에서는 취소가 제한될 수 있습니다. 상세 로그를 확인해 주세요.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: canCancel ? const Color(0xFF5A6D46) : OudColors.mutedText,
                                  fontWeight: FontWeight.w600,
                                ),
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
                  }),
                ],
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

class _OrderConfidenceBanner extends StatelessWidget {
  const _OrderConfidenceBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1E8),
        borderRadius: OudRadii.md,
        border: Border.all(color: const Color(0xFFE9D7C6)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: OudColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '주문 상태, 취소 가능 여부, 배송/환불 안내는 주문 상세 화면에서 확인할 수 있습니다.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF6A4A35), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
