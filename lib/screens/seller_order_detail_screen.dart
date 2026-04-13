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

        final canShip = manager.canSellerShip(order);
        final canCancel = manager.canSellerCancel(order);

        return Scaffold(
          appBar: AppBar(title: const Text('주문 상세 관리')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _statusGuidanceCard(order.status),
              const SizedBox(height: 10),
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
                          .map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ),
                          )
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
                        hintText: '배송 관련 메모를 입력해 주세요',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: !canShip
                            ? null
                            : () {
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
                    if (!canShip)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _shipDisabledReason(order.status),
                          style: const TextStyle(color: OudColors.mutedText),
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
                        hintText: '예: 재고 부족, 고객 요청',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: !canCancel
                            ? null
                            : () {
                                manager.markOrderCanceled(
                                  order.id,
                                  reason: _cancelReasonController.text,
                                  actor: '판매자',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('취소완료 처리했습니다.')),
                                );
                              },
                        child: const Text('취소완료 처리'),
                      ),
                    ),
                    if (!canCancel)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _cancelDisabledReason(order.status),
                          style: const TextStyle(color: OudColors.mutedText),
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
                    Text(order.addressSummary, style: const TextStyle(color: OudColors.mutedText)),
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
                    if (order.statusLogs.isEmpty)
                      const Text(
                        '아직 기록된 상태 로그가 없습니다.',
                        style: TextStyle(color: OudColors.mutedText),
                      )
                    else
                      ...order.statusLogs.map(
                        (log) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${DateFormat('MM.dd HH:mm').format(log.date)} · ${log.status} · ${log.actor}',
                            style: const TextStyle(color: OudColors.mutedText),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      '참고: 상태 변경 후 구매자 화면 반영까지 약간의 지연이 발생할 수 있습니다.',
                      style: TextStyle(fontSize: 12, color: OudColors.mutedText),
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
                        const Text('최종 결제금액', style: TextStyle(fontWeight: FontWeight.w800)),
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

  Widget _statusGuidanceCard(String status) {
    final message = switch (status) {
      '결제완료' => '결제완료 상태입니다. 재고/검수 확인 후 배송준비 또는 취소완료로 처리할 수 있습니다.',
      '배송준비' => '배송준비 상태입니다. 송장번호 입력 후 발송 처리 가능합니다.',
      '배송중' => '배송중 상태입니다. 구매자 문의 대응 및 배송완료 전환 관리가 필요합니다.',
      '배송완료' => '배송완료 상태입니다. 추가 상태 변경은 제한됩니다.',
      '취소요청' => '구매자 취소요청 상태입니다. 사유 확인 후 취소완료 처리해 주세요.',
      '취소완료' => '취소완료 상태입니다. 추가 상태 변경은 제한됩니다.',
      _ => '주문 상태를 확인한 후 가능한 작업을 진행해 주세요.',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1E8),
        borderRadius: OudRadii.md,
        border: Border.all(color: const Color(0xFFE9D7C6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: OudColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF6A4A35), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  String _shipDisabledReason(String status) {
    if (status == '배송중' || status == '배송완료') {
      return '이미 발송 처리된 주문입니다.';
    }
    if (status == '취소요청' || status == '취소완료') {
      return '취소 단계 주문은 발송 처리할 수 없습니다.';
    }
    return '현재 상태에서는 발송 처리를 할 수 없습니다.';
  }

  String _cancelDisabledReason(String status) {
    if (status == '배송중' || status == '배송완료') {
      return '배송 진행/완료 주문은 취소 처리가 제한됩니다.';
    }
    if (status == '취소완료') {
      return '이미 취소 완료된 주문입니다.';
    }
    return '현재 상태에서는 취소 처리를 할 수 없습니다.';
  }
}
