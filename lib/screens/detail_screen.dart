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
  var _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedOption =
        widget.product.options.isEmpty ? null : widget.product.options.first;
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final product = widget.product;
    final sale = product.isSale && product.salePrice != null;
    final price = sale ? product.salePrice! : product.price;
    final soldOut = product.stock == 0;
    final productReviews =
        manager.reviews.where((review) => review.productId == product.id).toList();
    final relatedProducts = manager.products
        .where((item) => item.id != product.id)
        .take(4)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('OUD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
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
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 124),
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
                          fontSize: 36,
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
            const OudSectionTitle(title: '상품 설명'),
            const SizedBox(height: 8),
            const Text(
              '고령토의 따뜻한 질감을 살린 제작 방식으로, 식탁 위에 오래 남는 오브제를 제안합니다. '
              '브러시 마감과 유약 흐름의 균형을 살려 하나씩 완성했습니다.',
              style: TextStyle(height: 1.6),
            ),
            const SizedBox(height: 20),
            const OudSectionTitle(title: '컬러 선택'),
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
            const OudSectionTitle(title: '사이즈'),
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
            const OudSectionTitle(title: '수량'),
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
            const SizedBox(height: 18),
            _reviewSection(productReviews),
            const SizedBox(height: 18),
            _shippingPolicySection(),
            const SizedBox(height: 18),
            _relatedProductsSection(relatedProducts),
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
                child: OudTapScale(
                  onTap: soldOut
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
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OudTapScale(
                  onTap: soldOut
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewSection(List<Review> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OudSectionTitle(
          title: '리뷰 ${reviews.length}건',
          trailing: TextButton(
            onPressed: () {},
            child: const Text('전체보기'),
          ),
        ),
        const SizedBox(height: 8),
        if (reviews.isEmpty)
          const OudSectionCard(
            child: Text(
              '아직 작성된 리뷰가 없습니다. 첫 리뷰를 남겨보세요.',
              style: TextStyle(color: OudColors.mutedText),
            ),
          )
        else
          ...reviews.take(2).map(_reviewCard),
      ],
    );
  }

  Widget _reviewCard(Review review) {
    final dateLabel = DateFormat('yyyy.MM.dd').format(review.date);
    final stars = '★' * review.rating.round().clamp(1, 5);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OudSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  stars,
                  style: const TextStyle(
                    color: OudColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(dateLabel, style: OudTypography.bodyMuted),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              review.comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shippingPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        OudSectionTitle(title: '배송/교환/환불 안내'),
        SizedBox(height: 8),
        OudSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '배송 안내',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                '주문 후 1~3일 내 발송되며, 도서산간 지역은 1~2일 추가 소요될 수 있습니다.',
                style: TextStyle(color: OudColors.mutedText, height: 1.4),
              ),
              SizedBox(height: 10),
              Text(
                '교환/환불',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                '수령 후 7일 이내 접수 가능하며, 사용 흔적이 있는 경우 교환/환불이 제한됩니다.',
                style: TextStyle(color: OudColors.mutedText, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _relatedProductsSection(List<Product> relatedProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OudSectionTitle(title: '함께 보면 좋은 상품'),
        const SizedBox(height: 8),
        if (relatedProducts.isEmpty)
          const OudSectionCard(
            child: Text('추천 상품이 없습니다.', style: OudTypography.bodyMuted),
          )
        else
          SizedBox(
            height: 188,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: relatedProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final item = relatedProducts[index];
                return InkWell(
                  borderRadius: OudRadii.md,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(product: item),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 150,
                    child: OudSectionCard(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: OudRadii.sm,
                            child: AspectRatio(
                              aspectRatio: 1.1,
                              child: item.image == null
                                  ? Container(color: OudColors.surface)
                                  : Image.asset(
                                      item.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(color: OudColors.surface),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '₩${NumberFormat('#,###', 'ko_KR').format(item.price)}',
                            style: const TextStyle(
                              color: OudColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
