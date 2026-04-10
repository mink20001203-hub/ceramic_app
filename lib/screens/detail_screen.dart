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
        centerTitle: true,
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
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (product.isNew)
                  const OudTag(label: '신상', bgColor: OudColors.sage, textColor: Color(0xFF32502E)),
                if (product.isSale)
                  const OudTag(label: '할인', bgColor: OudColors.primarySoft, textColor: OudColors.primary),
                const OudTag(label: '파손 재배송 보장'),
              ],
            ),
            const SizedBox(height: 10),
            Text(product.title, style: OudTypography.headingLg),
            const SizedBox(height: 4),
            Text(product.subTitle, style: const TextStyle(color: OudColors.mutedText, height: 1.4)),
            const SizedBox(height: 10),
            OudPriceText(price: unitPrice, original: sale ? product.price : null),
            const SizedBox(height: 6),
            Text(
              soldOut ? '현재 품절 상품입니다. 재입고 알림 신청을 권장합니다.' : '재고 ${product.stock}개 · 오늘 출고 가능',
              style: TextStyle(
                color: soldOut ? OudColors.danger : OudColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            _orderInfoCard(format, unitPrice, totalPrice, soldOut),
            const SizedBox(height: 12),
            const _TrustInfoCard(),
            const SizedBox(height: 12),
            _sizeMaterialCard(),
            const SizedBox(height: 12),
            _reviewCard(),
            const SizedBox(height: 12),
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
            onPlus: soldOut
                ? null
                : _quantity >= widget.product.stock
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('현재 재고보다 많은 수량은 선택할 수 없습니다.')),
                        );
                      }
                    : () => setState(() => _quantity++),
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

  Widget _sizeMaterialCard() {
    return const OudSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OudSectionTitle(title: '사이즈 · 재질 · 수작업 안내'),
          SizedBox(height: 10),
          Text('• 재질: 스톤웨어 기반 수작업 도자기', style: TextStyle(height: 1.45)),
          Text('• 특징: 유약 흐름, 점/결 무늬가 개체마다 다를 수 있음', style: TextStyle(height: 1.45)),
          Text('• 권장: 첫 사용 전 미온수 세척 후 건조', style: TextStyle(height: 1.45)),
          Text('• 주의: 급격한 온도 변화는 피하고, 파손 흔적 시 사용 중단', style: TextStyle(height: 1.45)),
          SizedBox(height: 8),
          Text(
            '실사용 팁: 컵/볼류는 밝은 조명 아래에서 표면 색감을 먼저 확인하면 만족도가 높습니다.',
            style: TextStyle(color: OudColors.mutedText, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard() {
    return const OudSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OudSectionTitle(title: '리뷰 요약'),
          SizedBox(height: 8),
          Row(
            children: [
              Text('평점 4.8', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: OudColors.primary)),
              SizedBox(width: 8),
              Text('(최근 30일 후기 기준)', style: TextStyle(color: OudColors.mutedText)),
            ],
          ),
          SizedBox(height: 8),
          Text('• “색감이 사진과 거의 같아서 만족”', style: TextStyle(height: 1.4)),
          Text('• “포장 상태가 꼼꼼해 파손 없이 도착”', style: TextStyle(height: 1.4)),
          Text('• “일상 식탁에 잘 어울려 재구매 의사 있음”', style: TextStyle(height: 1.4)),
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

class _TrustInfoCard extends StatelessWidget {
  const _TrustInfoCard();

  @override
  Widget build(BuildContext context) {
    return const OudSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OudSectionTitle(title: '배송 · 교환/반품'),
          SizedBox(height: 10),
          Text('• 기본 배송비 3,000원 / 50,000원 이상 무료배송', style: TextStyle(height: 1.45)),
          Text('• 평균 출고 1~2일, 도착 예상 2~4일', style: TextStyle(height: 1.45)),
          Text('• 파손/오배송은 수령 후 7일 이내 무상 처리', style: TextStyle(height: 1.45)),
          Text('• 단순 변심 교환/반품은 미사용 상태에서 신청 가능', style: TextStyle(height: 1.45)),
        ],
      ),
    );
  }
}
