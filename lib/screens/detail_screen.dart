import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import 'checkout_screen.dart';

class DetailScreen extends StatefulWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _selectedOption;
  var _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedOption =
        widget.product.options.isEmpty ? null : widget.product.options.first;
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.read<UserDataManager>();
    final product = widget.product;
    final sale = product.isSale && product.salePrice != null;
    final price = sale ? product.salePrice! : product.price;
    final soldOut = product.stock == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OUD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<UserDataManager>(
            builder: (_, m, __) {
              final fav = m.isFavorite(product);
              return IconButton(
                icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                color: fav ? OudColors.primary : OudColors.text,
                onPressed: () => m.toggleWishlist(product),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: OudRadii.xl,
              child: AspectRatio(
                aspectRatio: 1.08,
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
            const SizedBox(height: 16),
            Text(
              product.subTitle,
              style: const TextStyle(
                color: OudColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.title,
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            OudPriceText(
              price: price,
              original: sale ? product.price : null,
            ),
            const SizedBox(height: 10),
            Text(
              soldOut ? '현재 품절된 상품입니다.' : '재고 ${product.stock}개',
              style: TextStyle(
                color: soldOut ? OudColors.danger : OudColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'COLOR / STYLE',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: OudColors.mutedText,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.product.options.map((option) {
                final selected = _selectedOption == option;
                return ChoiceChip(
                  selected: selected,
                  label: Text(option),
                  onSelected: soldOut
                      ? null
                      : (_) => setState(() => _selectedOption = option),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'QUANTITY',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: OudColors.mutedText,
              ),
            ),
            const SizedBox(height: 8),
            OudQuantityStepper(
              value: _quantity,
              onMinus: soldOut || _quantity <= 1
                  ? null
                  : () => setState(() => _quantity -= 1),
              onPlus: soldOut || _quantity >= product.stock
                  ? null
                  : () => setState(() => _quantity += 1),
            ),
            const SizedBox(height: 20),
            const OudSectionCard(
              child: Text(
                '자연스러운 유약의 흐름과 둥근 실루엣을 중심으로 만든 수공예 작품입니다. '
                '테이블 위에서 조용히 존재감을 만드는 오브제로 제안합니다.',
                style: TextStyle(height: 1.6),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          color: OudColors.bg,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: soldOut
                      ? null
                      : () {
                          manager.addToCartMultiple(
                            product,
                            _quantity,
                            selectedOption: _selectedOption,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('장바구니에 담았습니다.')),
                          );
                        },
                  child: const Text('장바구니'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: soldOut
                      ? null
                      : () {
                          if (!manager.isLoggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('로그인 후 결제할 수 있습니다.')),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen.single(
                                product: product,
                                selectedOption: _selectedOption,
                                quantity: _quantity,
                              ),
                            ),
                          );
                        },
                  child: Text(soldOut ? '품절' : '바로 구매'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
