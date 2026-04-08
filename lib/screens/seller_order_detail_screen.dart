import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const SellerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<SellerOrderDetailScreen> createState() => _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  final _trackingController = TextEditingController();
  final _shippingMemoController = TextEditingController();
  final _cancelReasonController = TextEditingController();
  bool _controllersInitialized = false;

  static const List<String> _statusOptions = [
    '결제완료',
    '배송준비',
    '배송중',
    '배송완료',
    '취소요청',
    '취소완료',
  ];

  @override
  void dispose() {
    _trackingController.dispose();
    _shippingMemoController.dispose();
    _cancelReasonController.dispose();
    super.dispose();
  }

  void _initControllers(Order order) {
    if (_controllersInitialized) return;
    _trackingController.text = order.trackingNumber ?? '';
    _shippingMemoController.text = order.shippingMemo ?? '';
    _cancelReasonController.text = order.cancelReason ?? '';
    _controllersInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###', 'ko_KR');

    return Consumer<UserDataManager>(
      builder: (context, manager, _) {
        final order = manager.orders.firstWhere((o) => o.id == widget.orderId);
        _initControllers(order);

        return Scaffold(
          appBar: AppBar(title: const Text('주문 상세 관리')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              OudSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '주문번호 ${order.id}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                          .map((status) =>
                              DropdownMenuItem(value: status, child: Text(status)))
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
                    const Text('배송 처리', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _trackingController,
                      decoration: const InputDecoration(
                        labelText: '송장번호',
                        hintText: '예: 1234-5678-9000',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _shippingMemoController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '배송 메모',
                        hintText: '포장/배송 관련 메모를 입력해 주세요.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final tracking = _trackingController.text.trim();
                          if (tracking.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('송장번호를 입력해 주세요.')),
                            );
                            return;
                          }
                          manager.markOrderShipped(
                            order.id,
                            trackingNumber: tracking,
                            shippingMemo: _shippingMemoController.text,
                            actor: '판매자',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('발송 처리했습니다.')),
                          );
                        },
                        child: const Text('발송 처리'),
                      ),
                    ),
                    if (order.trackingNumber != null &&
                        order.trackingNumber!.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '현재 송장번호: ${order.trackingNumber}',
                        style: const TextStyle(color: OudColors.mutedText),
                      ),
                    ],
                    if (order.shippedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '발송 시각: ${DateFormat('yyyy.MM.dd HH:mm').format(order.shippedAt!)}',
                        style: const TextStyle(color: OudColors.mutedText),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OudSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('취소 처리', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cancelReasonController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '취소 사유',
                        hintText: '예: 재고 부족, 결제 오류',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          manager.markOrderCanceled(
                            order.id,
                            reason: _cancelReasonController.text,
                            actor: '판매자',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('취소 완료 처리했습니다.')),
                          );
                        },
                        child: const Text('취소 완료 처리'),
                      ),
                    ),
                    if (order.cancelReason != null &&
                        order.cancelReason!.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '취소 사유: ${order.cancelReason}',
                        style: const TextStyle(color: OudColors.mutedText),
                      ),
                    ],
                    if (order.canceledAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '취소 시각: ${DateFormat('yyyy.MM.dd HH:mm').format(order.canceledAt!)}',
                        style: const TextStyle(color: OudColors.mutedText),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OudSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('배송/결제 정보', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      order.addressSummary,
                      style: const TextStyle(color: OudColors.mutedText),
                    ),
                    const SizedBox(height: 10),
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
                    const Text('상태 로그', style: TextStyle(fontWeight: FontWeight.w800)),
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
                    const Text('주문 상품', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.title} (${item.option ?? '기본'}) x${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
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
                        const Text('최종 결제금액',
                            style: TextStyle(fontWeight: FontWeight.w800)),
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
