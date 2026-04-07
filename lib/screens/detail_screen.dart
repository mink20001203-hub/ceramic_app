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
            builder: (_, data, __) {
              final favorite = data.isFavorite(product);
              return IconButton(
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
                color: favorite ? OudColors.primary : OudColors.text,
                onPressed: () => data.toggleWishlist(product),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 118),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: OudRadii.xl,
              child: AspectRatio(
                aspectRatio: 1.06,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.subTitle,
                        style: const TextStyle(
                          color: Color(0xFF6D8A4B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 37,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: OudPriceText(
                    price: price,
                    original: sale ? product.price : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              soldOut ? '현재 품절된 상품입니다.' : '재고 ${product.stock}개',
              style: TextStyle(
                color: soldOut ? OudColors.danger : OudColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '상품 설명',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: OudColors.mutedText,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '고령토의 따뜻한 질감을 살린 제작 방식으로, 식탁 위에 오래 남는 오브제를 제안합니다. '
              '브러시 마감과 유약 흐름의 균형을 살려 하나씩 완성했습니다.',
              style: TextStyle(height: 1.6),
            ),
            const SizedBox(height: 20),
            const Text(
              'COLOR SELECTION',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: OudColors.mutedText,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (product.options.isEmpty
                      ? const ['샌드 베이지', '스톤 그레이', '테라코타']
                      : product.options)
                  .map((option) {
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
              'SIZE',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: OudColors.mutedText,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('Small (15cm)')),
                Chip(label: Text('Medium (22cm)')),
                Chip(label: Text('Large (30cm)')),
              ],
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
            const SizedBox(height: 18),
            const OudSectionCard(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: OudColors.primarySoft,
                    child: Icon(Icons.person, size: 18, color: OudColors.primary),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '김지수 작가 · 14건 게시물',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  OudTag(
                    label: 'Follow',
                    bgColor: OudColors.sage,
                    textColor: Color(0xFF32502E),
                  ),
                ],
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA6D388),
                    foregroundColor: const Color(0xFF24461B),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB34230),
                    foregroundColor: Colors.white,
                  ),
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
                  child: Text(soldOut ? '품절' : '바로 구매하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
