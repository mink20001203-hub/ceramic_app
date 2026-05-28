import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';

class MileageHistoryScreen extends StatelessWidget {
  const MileageHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final logs = List<MileageLog>.from(manager.mileageLogs)
      ..sort((a, b) => b.date.compareTo(a.date));
    final orders = List<Order>.from(manager.orders)..sort((a, b) => b.date.compareTo(a.date));
    final format = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(title: const Text('마일리지 내역')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          OudSectionCard(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '현재 보유 마일리지',
                    style: TextStyle(
                      color: OudColors.mutedText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${format.format(manager.mileage)}P',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: OudColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const OudSectionTitle(title: '적립/사용 내역'),
          const SizedBox(height: 8),
          if (logs.isEmpty && orders.isEmpty)
            const SizedBox(
              height: 180,
              child: OudEmptyState(
                title: '마일리지 내역이 없습니다',
                subtitle: '주문 또는 리뷰 작성 시 내역이 표시됩니다.',
                icon: Icons.payments_outlined,
              ),
            )
          else if (logs.isNotEmpty)
            ...logs.map(
              (log) => _historyRow(
                title: log.title,
                subtitle: log.description,
                amount: log.delta,
                date: log.date,
              ),
            )
          else
            ...orders.expand((order) {
              final rows = <Widget>[];
              if (order.mileageUsed > 0) {
                rows.add(
                  _historyRow(
                    title: '주문 사용',
                    subtitle: '주문번호 ${order.id}',
                    amount: -order.mileageUsed,
                    date: order.date,
                  ),
                );
              }
              rows.add(
                _historyRow(
                  title: '주문 적립',
                  subtitle: '주문번호 ${order.id}',
                  amount: 500,
                  date: order.date,
                ),
              );
              return rows;
            }),
          if (manager.reviews.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...manager.reviews.map(
              (review) => _historyRow(
                title: '리뷰 적립',
                subtitle: review.productName,
                amount: 100,
                date: review.date,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _historyRow({
    required String title,
    required String subtitle,
    required int amount,
    required DateTime date,
  }) {
    final dateLabel = DateFormat('yyyy.MM.dd').format(date);
    final positive = amount >= 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OudSectionCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('$subtitle · $dateLabel',
                      style: const TextStyle(color: OudColors.mutedText)),
                ],
              ),
            ),
            Text(
              '${positive ? '+' : ''}${amount}P',
              style: TextStyle(
                color: positive ? const Color(0xFF4D6A3A) : const Color(0xFF9D4A3E),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
