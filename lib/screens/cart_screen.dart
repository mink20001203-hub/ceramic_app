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
          return const OudEmptyState(
            title: '장바구니가 비어 있습니다',
            subtitle: '마음에 드는 작품을 담아보세요.',
            icon: Icons.shopping_bag_outlined,
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Text(
                    '장바구니 ${items.length}건',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: manager.clearCart,
                    child: const Text('전체 삭제'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  final sale =
                      item.product.isSale && item.product.salePrice != null;
                  final unit = sale ? item.product.salePrice! : item.product.price;
                  final total = unit * item.quantity;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OudSectionCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: OudRadii.sm,
                            child: SizedBox(
                              width: 92,
                              height: 92,
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
                                Text(
                                  item.product.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (item.option != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      item.option!,
                                      style: const TextStyle(
                                        color: OudColors.mutedText,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  '₩${format.format(total)}',
                                  style: const TextStyle(
                                    color: OudColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
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
                          IconButton(
                            onPressed: () =>
                                manager.removeSingleItem(item.product.id, item.option),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              decoration: const BoxDecoration(
                color: OudColors.bg,
                border: Border(top: BorderSide(color: OudColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '총 결제 금액  ₩${format.format(manager.totalAmount)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () {
                        final soldOut = items.any((i) => i.product.stock == 0);
                        final overStock =
                            items.any((i) => i.quantity > i.product.stock);
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
                      child: const Text('결제 진행'),
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
