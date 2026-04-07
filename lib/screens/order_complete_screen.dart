import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';

class OrderCompleteScreen extends StatelessWidget {
  final int finalAmount;
  final int itemCount;

  const OrderCompleteScreen({
    super.key,
    required this.finalAmount,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###', 'ko_KR');
    final manager = context.watch<UserDataManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('주문 완료')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: OudColors.sage,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: OudColors.successText,
                size: 44,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '주문이 완료되었습니다',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              '${manager.userName}님, 주문 내역을 확인해 주세요.',
              style: const TextStyle(color: OudColors.mutedText),
            ),
            const SizedBox(height: 20),
            OudSectionCard(
              child: Column(
                children: [
                  OudAmountRow(label: '주문 상품', value: '${itemCount}개'),
                  OudAmountRow(
                    label: '결제 금액',
                    value: '₩${format.format(finalAmount)}',
                    emphasize: true,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OudTapScale(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('홈으로 이동'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
