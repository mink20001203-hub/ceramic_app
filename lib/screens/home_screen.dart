import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _categories = <String>[
    '전체',
    '컵',
    '접시',
    '볼',
    '화병',
    '트레이',
    '세트',
  ];

  String _selectedCategory = '전체';

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final products = manager.products;
    final filtered = _selectedCategory == '전체'
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();

    final highlighted = filtered.where((p) => p.isNew || p.isSale).take(6).toList();
    final bestByStock = List<Product>.from(filtered)
      ..sort((a, b) => b.stock.compareTo(a.stock));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _heroCard(filtered.length, manager.products.length, manager.reviewCount),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _categoryChips(),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: OudSectionTitle(title: '추천 상품'),
          ),
        ),
        SliverToBoxAdapter(
          child: OudFadeSwitcher(
            child: manager.productsLoading
                ? const SizedBox(
                    key: ValueKey('home-loading'),
                    height: 220,
                    child: OudLoadingState(
                      title: '상품을 불러오는 중입니다',
                      subtitle: '잠시만 기다려 주세요.',
                    ),
                  )
                : filtered.isEmpty
                    ? const SizedBox(
                        key: ValueKey('home-empty'),
                        height: 220,
                        child: OudEmptyState(
                          title: '조건에 맞는 상품이 없습니다',
                          subtitle: '카테고리를 바꿔서 다시 확인해 주세요.',
                          icon: Icons.inventory_2_outlined,
                        ),
                      )
                    : GridView.builder(
                        key: ValueKey('home-grid-$_selectedCategory'),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                        itemCount: filtered.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (_, index) => ProductCard(product: filtered[index]),
                      ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: OudSectionTitle(title: '신상 · 할인'),
          ),
        ),
        SliverToBoxAdapter(child: _highlightSection(highlighted)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: OudSectionTitle(title: '카테고리 베스트'),
          ),
        ),
        SliverToBoxAdapter(child: _bestSellerSection(bestByStock.take(5).toList())),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }

  Widget _heroCard(int filteredCount, int totalCount, int reviewCount) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F3EC), Color(0xFFEFE3D6)],
        ),
        borderRadius: OudRadii.xl,
        border: Border.all(color: OudColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OUD 컬렉션',
            style: TextStyle(fontSize: 13, color: OudColors.mutedText, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text('오늘 고르기 좋은 도자기', style: OudTypography.headingMd),
          const SizedBox(height: 10),
          const Text(
            '머그, 접시, 볼, 화병까지 카테고리별로 빠르게 둘러보세요.',
            style: TextStyle(height: 1.45, color: OudColors.text),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _heroStat('노출 상품', '$filteredCount'),
              const SizedBox(width: 8),
              _heroStat('전체 상품', '$totalCount'),
              const SizedBox(width: 8),
              _heroStat('리뷰', '$reviewCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: OudRadii.md,
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text(label, style: const TextStyle(fontSize: 11, color: OudColors.mutedText)),
          ],
        ),
      ),
    );
  }

  Widget _categoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final selected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              selectedColor: OudColors.primarySoft,
              side: const BorderSide(color: OudColors.border),
              labelStyle: TextStyle(
                color: selected ? OudColors.primary : OudColors.text,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) => setState(() => _selectedCategory = category),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _highlightSection(List<Product> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: SizedBox(
          height: 100,
          child: OudEmptyState(
            title: '신상/할인 상품이 없습니다',
            subtitle: '다른 카테고리에서 확인해 보세요.',
            icon: Icons.new_releases_outlined,
          ),
        ),
      );
    }

    return SizedBox(
      height: 146,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final item = products[index];
          return SizedBox(
            width: 260,
            child: OudSectionCard(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: OudRadii.md,
                    child: SizedBox(
                      width: 82,
                      height: 82,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: OudColors.mutedText),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (item.isNew)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: OudTag(
                                  label: '신상',
                                  bgColor: OudColors.sage,
                                  textColor: Color(0xFF32502E),
                                ),
                              ),
                            if (item.isSale)
                              const OudTag(
                                label: '할인',
                                bgColor: OudColors.primarySoft,
                                textColor: OudColors.primary,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bestSellerSection(List<Product> products) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: OudSectionCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: products.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: OudColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$rank',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
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
                  Text(
                    '재고 ${item.stock}',
                    style: const TextStyle(color: OudColors.mutedText),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
