import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    return Consumer<UserDataManager>(
      builder: (context, manager, _) {
        final order = manager.orders.firstWhere((o) => o.id == orderId);
        final canManageOrder = manager.isLoggedIn && manager.isSeller;
        final canBuyerRequestCancel =
            manager.isLoggedIn && !manager.isSeller && manager.canRequestCancellation(order);

        return Scaffold(
          appBar: AppBar(
            title: const Text('주문 상세'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OudSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '주문번호 ${order.id}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('yyyy.MM.dd HH:mm').format(order.date)} · ${order.status}',
                        style: const TextStyle(color: OudColors.mutedText),
                      ),
                      const SizedBox(height: 10),
                      _statusPill(order.status),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                OudSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OudSectionTitle(title: '상태 로그'),
                      const SizedBox(height: 8),
                      ...order.statusLogs.map(
                        (log) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
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
                if (canManageOrder && order.status != '배송완료')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => manager.advanceOrderStatus(order.id, actor: '판매자'),
                        child: const Text('다음 상태로 변경(판매자)'),
                      ),
                    ),
                  ),
                if (canBuyerRequestCancel)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _showCancelRequestDialog(context, manager, order.id),
                        child: const Text('취소 요청'),
                      ),
                    ),
                  ),
                OudSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OudSectionTitle(title: '배송/결제 정보'),
                      const SizedBox(height: 8),
                      Text(order.addressSummary, style: const TextStyle(color: OudColors.mutedText)),
                      const SizedBox(height: 4),
                      Text('결제수단: ${order.paymentMethodLabel}', style: const TextStyle(color: OudColors.mutedText)),
                      Text('결제상태: ${order.paymentStatus}', style: const TextStyle(color: OudColors.mutedText)),
                      if (order.status == '취소요청' || order.status == '취소완료') ...[
                        const SizedBox(height: 8),
                        Text(
                          '취소 사유: ${order.cancelReason ?? '사유 없음'}',
                          style: const TextStyle(color: OudColors.mutedText),
                        ),
                        if (order.canceledAt != null)
                          Text(
                            '취소 완료 시각: ${DateFormat('yyyy.MM.dd HH:mm').format(order.canceledAt!)}',
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
                      const OudSectionTitle(title: '주문 상품'),
                      const SizedBox(height: 6),
                      ...order.items.map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.product.title),
                          subtitle: Text('옵션: ${item.option ?? '기본'} · 수량: ${item.quantity}'),
                          trailing: Text(
                            '${priceFormat.format(item.unitPrice * item.quantity)}원',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                OudSectionCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('총 결제금액', style: TextStyle(fontWeight: FontWeight.w800)),
                          const Spacer(),
                          Text(
                            '${priceFormat.format(order.totalAmount)}원',
                            style: const TextStyle(
                              color: OudColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      if (order.discountAmount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Text('할인', style: TextStyle(color: OudColors.mutedText)),
                              const Spacer(),
                              Text(
                                '-${priceFormat.format(order.discountAmount)}원',
                                style: const TextStyle(color: OudColors.mutedText),
                              ),
                            ],
                          ),
                        ),
                      if (order.couponTitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Text('쿠폰', style: TextStyle(color: OudColors.mutedText)),
                              const Spacer(),
                              Text(order.couponTitle!, style: const TextStyle(color: OudColors.mutedText)),
                            ],
                          ),
                        ),
                      if (order.mileageUsed > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Text('마일리지 사용', style: TextStyle(color: OudColors.mutedText)),
                              const Spacer(),
                              Text('${order.mileageUsed}P', style: const TextStyle(color: OudColors.mutedText)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    onPressed: () {
                      int added = 0;
                      int skipped = 0;
                      for (final item in order.items) {
                        if (item.product.stock == 0) {
                          skipped += item.quantity;
                          continue;
                        }
                        final addQty = item.quantity > item.product.stock ? item.product.stock : item.quantity;
                        for (int i = 0; i < addQty; i++) {
                          manager.addToCart(item.product, selectedOption: item.option);
                        }
                        added += addQty;
                        if (addQty < item.quantity) {
                          skipped += item.quantity - addQty;
                        }
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            added == 0
                                ? '품절로 장바구니에 담을 수 없습니다.'
                                : skipped > 0
                                    ? '재고 부족으로 일부만 담았습니다.'
                                    : '장바구니에 담았습니다.',
                          ),
                        ),
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

  Widget _statusPill(String status) {
    final isCancel = status.contains('취소');
    final bg = isCancel ? const Color(0xFFF6DDDA) : OudColors.surface;
    final fg = isCancel ? const Color(0xFF9D4A3E) : OudColors.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: OudRadii.pill),
      child: Text(status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Future<void> _showCancelRequestDialog(
    BuildContext context,
    UserDataManager manager,
    String orderId,
  ) async {
    final reasonController = TextEditingController();
    final requested = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('주문 취소 요청'),
            content: TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '취소 사유를 입력해 주세요 (선택)',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('닫기'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('요청'),
              ),
            ],
          ),
        ) ??
        false;

    if (!requested) {
      reasonController.dispose();
      return;
    }

    manager.requestOrderCancellation(orderId, reason: reasonController.text, actor: '구매자');
    reasonController.dispose();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('취소요청이 접수되었습니다. 판매자 확인 후 처리됩니다.')),
    );
  }
}
