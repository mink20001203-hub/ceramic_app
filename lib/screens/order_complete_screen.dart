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
      appBar: AppBar(
        title: const Text('주문 완료'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: OudColors.sage,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: OudColors.successText,
                  size: 46,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '주문이 완료되었습니다',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '${manager.userName}님의 주문 내역을 확인해 주세요.',
                style: const TextStyle(color: OudColors.mutedText),
              ),
            ),
            const SizedBox(height: 22),
            OudSectionCard(
              child: Column(
                children: [
                  OudAmountRow(label: '주문 상품', value: '$itemCount개'),
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
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
