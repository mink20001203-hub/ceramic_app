import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###', 'ko_KR');
    return Consumer<UserDataManager>(
      builder: (context, manager, _) {
        final items = manager.items;
        if (items.isEmpty) {
          return const OudFadeSwitcher(
            child: OudEmptyState(
              key: ValueKey('cart-empty'),
              title: '장바구니가 비어 있습니다',
              subtitle: '마음에 드는 상품을 담아보세요.',
              icon: Icons.shopping_bag_outlined,
            ),
          );
        }

        final subtotal = manager.totalAmount;
        final shippingFee = subtotal >= 50000 ? 0 : 3000;
        final finalAmount = subtotal + shippingFee;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.radio_button_checked,
                    size: 18,
                    color: OudColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '전체 선택 (${items.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: OudColors.text,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: manager.clearCart,
                    child: const Text(
                      '선택 삭제',
                      style: TextStyle(color: OudColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  final sale =
                      item.product.isSale && item.product.salePrice != null;
                  final unit = sale ? item.product.salePrice! : item.product.price;
                  final total = unit * item.quantity;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Icon(
                            Icons.radio_button_checked,
                            size: 18,
                            color: OudColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: OudRadii.sm,
                          child: SizedBox(
                            width: 90,
                            height: 90,
                            child: item.product.image == null
                                ? Container(color: OudColors.surface)
                                : Image.asset(
                                    item.product.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: OudColors.surface),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.product.title,
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w800,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: OudColors.mutedText,
                                    ),
                                    onPressed: () => manager.removeSingleItem(
                                      item.product.id,
                                      item.option,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                item.product.subTitle,
                                style: const TextStyle(color: OudColors.mutedText),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₩${format.format(total)}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: OudColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              OudQuantityStepper(
                                value: item.quantity,
                                onMinus: () => manager.decrementQuantity(
                                  item.product.id,
                                  item.option,
                                ),
                                onPlus: () => manager.incrementQuantity(
                                  item.product.id,
                                  item.option,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              decoration: const BoxDecoration(
                color: OudColors.bg,
                border: Border(top: BorderSide(color: OudColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('결제 요약', style: OudTypography.headingMd),
                  const SizedBox(height: 10),
                  OudAmountRow(
                    label: '총 상품 금액',
                    value: '₩${format.format(subtotal)}',
                  ),
                  OudAmountRow(
                    label: '배송비',
                    value: '₩${format.format(shippingFee)}',
                  ),
                  const SizedBox(height: 10),
                  OudAmountRow(
                    label: '결제 예정 금액',
                    value: '₩${format.format(finalAmount)}',
                    emphasize: true,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final soldOut = items.any((item) => item.product.stock == 0);
                        final overStock =
                            items.any((item) => item.quantity > item.product.stock);
                        if (soldOut || overStock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('재고를 먼저 확인해 주세요.')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen.cart(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: Text('결제하기  ₩${format.format(finalAmount)}  →'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
