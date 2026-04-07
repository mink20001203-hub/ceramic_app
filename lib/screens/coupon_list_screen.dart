import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';

class CouponListScreen extends StatelessWidget {
  const CouponListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final coupons = manager.coupons;
    final pendingReviews = manager.purchasedProducts
        .where((product) => !manager.hasReview(product.id))
        .take(3)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('OUD')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Text('마이베네핏', style: OudTypography.headingXl),
          const Text(
            '나의 쿠폰과 작성 가능한 리뷰를 확인해 보세요.',
            style: TextStyle(color: OudColors.mutedText),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OudSectionCard(
                  child: _metric(
                    'AVAILABLE COUPONS',
                    '${manager.availableCouponCount}장',
                    const Color(0xFFC56D5A),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OudSectionCard(
                  child: _metric(
                    'PENDING REVIEWS',
                    '${pendingReviews.length}건',
                    const Color(0xFF5A7A3E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OudSectionTitle(
            title: '보유 쿠폰',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${coupons.length}',
                  style: const TextStyle(
                    color: OudColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showCouponRegisterDialog(context),
                  child: const Text(
                    '쿠폰 등록하기',
                    style: TextStyle(color: OudColors.primary),
                  ),
                ),
              ],
            ),
          ),
          OudFadeSwitcher(
            child: coupons.isEmpty
                ? const SizedBox(
                    key: ValueKey('coupon-empty'),
                    height: 160,
                    child: OudEmptyState(
                      title: '쿠폰이 없습니다',
                      subtitle: '이벤트나 첫 구매 혜택을 확인해 보세요.',
                      icon: Icons.confirmation_number_outlined,
                    ),
                  )
                : Column(
                    key: const ValueKey('coupon-list'),
                    children:
                        coupons.map((coupon) => _couponTile(coupon, context)).toList(),
                  ),
          ),
          const SizedBox(height: 12),
          const OudSectionTitle(title: '작성 가능한 리뷰'),
          const SizedBox(height: 8),
          OudFadeSwitcher(
            child: pendingReviews.isEmpty
                ? const SizedBox(
                    key: ValueKey('review-empty'),
                    height: 120,
                    child: OudEmptyState(
                      title: '작성 가능한 리뷰가 없습니다',
                      subtitle: '구매 후 리뷰를 작성하면 마일리지를 받을 수 있어요.',
                      icon: Icons.rate_review_outlined,
                    ),
                  )
                : Column(
                    key: const ValueKey('review-list'),
                    children: pendingReviews
                        .map(
                          (product) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: OudSectionCard(
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: OudRadii.sm,
                                    child: SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: product.image == null
                                          ? Container(color: OudColors.surface)
                                          : Image.asset(
                                              product.image!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(color: OudColors.surface),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'HANDMADE',
                                          style: TextStyle(
                                            color: OudColors.mutedText,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          product.title,
                                          style:
                                              const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        const Text(
                                          '리뷰 작성 시 500P 적립',
                                          style: TextStyle(color: OudColors.mutedText),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const OudTag(
                                    label: 'Write Review',
                                    bgColor: OudColors.sage,
                                    textColor: Color(0xFF32502E),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  void _showCouponRegisterDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('쿠폰 등록'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '쿠폰 코드를 입력하세요 (예: WELCOME10)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              final message =
                  context.read<UserDataManager>().redeemCouponCode(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }

  Widget _metric(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: OudColors.mutedText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _couponTile(Coupon coupon, BuildContext context) {
    final format = NumberFormat('#,###', 'ko_KR');
    final used = coupon.isUsed;
    final amountText =
        coupon.discountAmount > 0 ? '₩${format.format(coupon.discountAmount)}' : '무료배송';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OudSectionCard(
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: used ? const Color(0xFFE4E4E4) : OudColors.primarySoft,
                borderRadius: OudRadii.md,
              ),
              alignment: Alignment.center,
              child: Text(
                used ? 'Used' : amountText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: used ? OudColors.mutedText : OudColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${format.format(coupon.minOrderAmount)}원 이상 주문 시 사용 가능',
                    style: const TextStyle(color: OudColors.mutedText),
                  ),
                ],
              ),
            ),
            if (!used)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(88, 38),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text('Use Now'),
              ),
          ],
        ),
      ),
    );
  }
}
