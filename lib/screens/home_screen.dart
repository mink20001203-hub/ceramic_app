import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final products = manager.products;
    final featured = products.take(4).toList();
    final newArrivals = products.where((product) => product.isNew).take(6).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _heroCard(manager),
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
            padding: EdgeInsets.fromLTRB(16, 24, 16, 10),
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
                      title: '상품 목록을 불러오는 중입니다',
                      subtitle: '잠시만 기다려 주세요',
                    ),
                  )
                : products.isEmpty
                    ? const SizedBox(
                        key: ValueKey('home-empty'),
                        height: 220,
                        child: OudEmptyState(
                          title: '등록된 상품이 없습니다',
                          subtitle: '관리자 또는 판매자에서 상품을 먼저 등록해 주세요',
                          icon: Icons.inventory_2_outlined,
                        ),
                      )
                    : GridView.builder(
                        key: const ValueKey('home-grid'),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                        itemCount: products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (_, index) => ProductCard(product: products[index]),
                      ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: OudSectionTitle(title: '신상품'),
          ),
        ),
        SliverToBoxAdapter(
          child: _newArrivalsSection(newArrivals.isEmpty ? featured : newArrivals),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }

  Widget _heroCard(UserDataManager manager) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F3EE), Color(0xFFEFE7DD)],
        ),
        borderRadius: OudRadii.xl,
        border: Border.all(color: OudColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 도자기 큐레이션',
            style: TextStyle(fontSize: 13, color: OudColors.mutedText, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text('핸드메이드 감성을 일상에 담다', style: OudTypography.headingMd),
          const SizedBox(height: 10),
          const Text(
            '작가의 감성과 실사용 품질을 함께 담은 도자기 상품을 둘러보세요.',
            style: TextStyle(height: 1.5, color: OudColors.text),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _heroStat('상품', '${manager.products.length}'),
              const SizedBox(width: 8),
              _heroStat('리뷰', '${manager.reviewCount}'),
              const SizedBox(width: 8),
              _heroStat('마일리지', '${manager.mileage}'),
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
          color: Colors.white.withValues(alpha: 0.75),
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
    const categories = <String>['전체', '머그', '볼', '화병', '플레이트', '인테리어'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(category),
                  side: const BorderSide(color: OudColors.border),
                  backgroundColor: category == '전체' ? OudColors.primarySoft : Colors.white,
                  labelStyle: TextStyle(
                    color: category == '전체' ? OudColors.primary : OudColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _newArrivalsSection(List<Product> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: SizedBox(
          height: 120,
          child: OudEmptyState(
            title: '신상품이 아직 없습니다',
            subtitle: '다음 업데이트에서 새 상품이 추가됩니다',
            icon: Icons.new_releases_outlined,
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
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
                      width: 78,
                      height: 78,
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
                          style: const TextStyle(fontSize: 12, color: OudColors.mutedText),
                        ),
                        const SizedBox(height: 8),
                        const OudTag(
                          label: '신상품',
                          bgColor: OudColors.sage,
                          textColor: OudColors.successText,
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
}
