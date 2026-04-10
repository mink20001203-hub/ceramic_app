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
              subtitle: '원하는 상품을 담아 결제를 진행해 보세요.',
              icon: Icons.shopping_bag_outlined,
            ),
          );
        }

        final subtotal = manager.totalAmount;
        final shippingFee = subtotal >= 50000 ? 0 : 3000;
        final finalAmount = subtotal + shippingFee;
        final groupedBySeller = _groupBySeller(items);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked, size: 18, color: OudColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '총 ${items.length}개 상품',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: OudColors.text),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: manager.clearCart,
                    child: const Text('전체 삭제', style: TextStyle(color: OudColors.primary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                children: [
                  ...groupedBySeller.entries.map(
                    (entry) => _sellerSection(entry.key, entry.value, manager, format),
                  ),
                ],
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
                  OudAmountRow(label: '총 상품 금액', value: '₩${format.format(subtotal)}'),
                  OudAmountRow(label: '배송비', value: '₩${format.format(shippingFee)}'),
                  const SizedBox(height: 6),
                  Text(
                    shippingFee == 0 ? '무료배송 적용' : '50,000원 이상 주문 시 무료배송',
                    style: const TextStyle(color: OudColors.mutedText),
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
                        final overStock = items.any((item) => item.quantity > item.product.stock);
                        if (soldOut || overStock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('품절 또는 재고 부족 상품이 있습니다.')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CheckoutScreen.cart()),
                        );
                      },
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                      child: Text('결제하기  ₩${format.format(finalAmount)}'),
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

  Map<String, List<CartItem>> _groupBySeller(List<CartItem> items) {
    final grouped = <String, List<CartItem>>{};
    for (final item in items) {
      final seller = item.product.sellerId?.trim();
      final key = (seller == null || seller.isEmpty) ? '일반 판매자' : seller;
      grouped.putIfAbsent(key, () => <CartItem>[]);
      grouped[key]!.add(item);
    }
    return grouped;
  }

  Widget _sellerSection(
    String sellerId,
    List<CartItem> sellerItems,
    UserDataManager manager,
    NumberFormat format,
  ) {
    final sectionTotal = sellerItems.fold<int>(0, (sum, item) {
      final sale = item.product.isSale && item.product.salePrice != null;
      final unit = sale ? item.product.salePrice! : item.product.price;
      return sum + (unit * item.quantity);
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: OudSectionCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '판매자 $sellerId',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text(
                  '소계 ₩${format.format(sectionTotal)}',
                  style: const TextStyle(color: OudColors.mutedText, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...sellerItems.map((item) => _cartItemTile(item, manager, format)),
          ],
        ),
      ),
    );
  }

  Widget _cartItemTile(CartItem item, UserDataManager manager, NumberFormat format) {
    final sale = item.product.isSale && item.product.salePrice != null;
    final unit = sale ? item.product.salePrice! : item.product.price;
    final total = unit * item.quantity;
    final soldOut = item.product.stock == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      errorBuilder: (_, __, ___) => Container(color: OudColors.surface),
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.1),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: OudColors.mutedText),
                      onPressed: () => manager.removeSingleItem(item.product.id, item.option),
                    ),
                  ],
                ),
                Text(
                  item.option == null ? item.product.subTitle : '${item.product.subTitle} / ${item.option}',
                  style: const TextStyle(color: OudColors.mutedText),
                ),
                if (soldOut)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '품절 상태 상품입니다',
                      style: TextStyle(color: OudColors.danger, fontWeight: FontWeight.w700),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  '₩${format.format(total)}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: OudColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                OudQuantityStepper(
                  value: item.quantity,
                  onMinus: () => manager.decrementQuantity(item.product.id, item.option),
                  onPlus: soldOut ? null : () => manager.incrementQuantity(item.product.id, item.option),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
