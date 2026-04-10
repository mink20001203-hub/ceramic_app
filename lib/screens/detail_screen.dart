import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.product.options.isNotEmpty ? widget.product.options.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final format = NumberFormat('#,###', 'ko_KR');
    final product = widget.product;
    final sale = product.isSale && product.salePrice != null;
    final unitPrice = sale ? product.salePrice! : product.price;
    final totalPrice = unitPrice * _quantity;
    final soldOut = product.stock == 0;
    final favorite = manager.isFavorite(product);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OUD'),
        actions: [
          IconButton(
            onPressed: () => manager.toggleWishlist(product),
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
              color: favorite ? OudColors.primary : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 128),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageCard(product, soldOut),
            const SizedBox(height: 16),
            Row(
              children: [
                if (product.isNew) const OudTag(label: '신상', bgColor: OudColors.sage, textColor: Color(0xFF32502E)),
                if (product.isNew && product.isSale) const SizedBox(width: 6),
                if (product.isSale) const OudTag(label: '할인', bgColor: OudColors.primarySoft, textColor: OudColors.primary),
              ],
            ),
            if (product.isNew || product.isSale) const SizedBox(height: 10),
            Text(product.title, style: OudTypography.headingLg),
            const SizedBox(height: 4),
            Text(product.subTitle, style: const TextStyle(color: OudColors.mutedText, height: 1.4)),
            const SizedBox(height: 12),
            OudPriceText(price: unitPrice, original: sale ? product.price : null),
            const SizedBox(height: 6),
            Text(
              soldOut ? '현재 품절 상품입니다.' : '재고 ${product.stock}개',
              style: TextStyle(
                color: soldOut ? OudColors.danger : OudColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            _orderInfoCard(format, unitPrice, totalPrice, soldOut),
            const SizedBox(height: 14),
            _descriptionCard(),
            const SizedBox(height: 14),
            _relatedCard(manager),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: OudColors.bg,
            border: Border(top: BorderSide(color: OudColors.border)),
          ),
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
                  child: const Text('바로 구매'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageCard(Product product, bool soldOut) {
    return ClipRRect(
      borderRadius: OudRadii.xl,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: product.image == null
                ? Container(color: OudColors.surface)
                : Image.asset(
                    product.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: OudColors.surface),
                  ),
          ),
          if (soldOut)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.22),
                alignment: Alignment.center,
                child: const OudTag(
                  label: '품절',
                  bgColor: Color(0xCC2F2E2B),
                  textColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _orderInfoCard(NumberFormat format, int unitPrice, int totalPrice, bool soldOut) {
    return OudSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OudSectionTitle(title: '주문 정보'),
          const SizedBox(height: 10),
          if (widget.product.options.isNotEmpty) ...[
            const Text('옵션', style: OudTypography.label),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.product.options.map((option) {
                final selected = option == _selectedOption;
                return ChoiceChip(
                  label: Text(option),
                  selected: selected,
                  selectedColor: OudColors.primarySoft,
                  side: const BorderSide(color: OudColors.border),
                  labelStyle: TextStyle(
                    color: selected ? OudColors.primary : OudColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: soldOut ? null : (_) => setState(() => _selectedOption = option),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          const Text('수량', style: OudTypography.label),
          const SizedBox(height: 6),
          OudQuantityStepper(
            value: _quantity,
            onMinus: _quantity > 1 ? () => setState(() => _quantity--) : null,
            onPlus: soldOut || _quantity >= widget.product.stock ? null : () => setState(() => _quantity++),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: OudColors.border),
          const SizedBox(height: 10),
          OudAmountRow(label: '상품 금액', value: '₩${format.format(unitPrice)}'),
          OudAmountRow(label: '총 수량', value: '$_quantity개'),
          OudAmountRow(label: '예상 합계', value: '₩${format.format(totalPrice)}', emphasize: true),
        ],
      ),
    );
  }

  Widget _descriptionCard() {
    return const OudSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OudSectionTitle(title: '상품 설명'),
          SizedBox(height: 10),
          Text(
            '작가의 수작업 공정으로 제작된 도자기입니다. 유약의 흐름과 색감은 개체마다 차이가 있으며, 전자레인지/식기세척기 사용 가능 여부는 상세 옵션에서 확인해 주세요.',
            style: TextStyle(height: 1.55, color: OudColors.text),
          ),
        ],
      ),
    );
  }

  Widget _relatedCard(UserDataManager manager) {
    final related = manager.products
        .where((item) => item.category == widget.product.category && item.id != widget.product.id)
        .take(3)
        .toList();
    if (related.isEmpty) return const SizedBox.shrink();

    return OudSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OudSectionTitle(title: '같은 카테고리 상품'),
          const SizedBox(height: 8),
          ...related.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: OudRadii.sm,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: item.image == null
                          ? Container(color: OudColors.surface)
                          : Image.asset(
                              item.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: OudColors.surface),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
