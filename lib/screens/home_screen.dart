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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final products = manager.products;
    final featured = products.take(6).toList();
    final recent = products.reversed.take(3).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _creatorHero(manager)),
        SliverToBoxAdapter(child: _tabStrip()),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 212,
            child: TabBarView(
              controller: _tabController,
              children: [
                _aboutPane(),
                _worksPane(featured),
                _reviewPane(manager),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
            child: Text('작품 목록', style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        if (manager.productsLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (products.isEmpty)
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 240,
              child: OudEmptyState(
                title: '등록된 상품이 없습니다',
                subtitle: '잠시 후 다시 확인해 주세요',
                icon: Icons.inventory_2_outlined,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductCard(product: products[index]),
                childCount: products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.69,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('최근 포스트', style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _postCard(recent[index]),
            childCount: recent.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }

  Widget _creatorHero(UserDataManager manager) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: OudColors.surface,
            child: Icon(Icons.person, size: 46, color: OudColors.mutedText),
          ),
          const SizedBox(height: 10),
          const Text(
            'OUD (오우드)',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statItem('FOLLOWERS', '1.2K'),
              _statItem('리뷰', '${manager.reviewCount}'),
              _statItem('작품', '${manager.products.length}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              OudTag(
                label: '팔로우',
                bgColor: OudColors.primarySoft,
                textColor: OudColors.primary,
              ),
              SizedBox(width: 8),
              OudTag(
                label: '메시지',
                bgColor: OudColors.sage,
                textColor: Color(0xFF32502E),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: OudColors.text,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: OudColors.mutedText,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      decoration: BoxDecoration(
        color: OudColors.surface,
        borderRadius: OudRadii.pill,
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const BoxDecoration(
          color: OudColors.card,
          borderRadius: OudRadii.pill,
        ),
        labelColor: OudColors.text,
        unselectedLabelColor: OudColors.mutedText,
        tabs: const [
          Tab(text: '작가 소개'),
          Tab(text: '스토리'),
          Tab(text: '리뷰'),
        ],
      ),
    );
  }

  Widget _aboutPane() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: OudSectionCard(
        child: Text(
          '대지를 닮은 컬러와 절제된 형태를 중심으로, 일상 테이블 위에 오래 머무는 세라믹을 만듭니다.',
          style: TextStyle(height: 1.6, color: OudColors.text),
        ),
      ),
    );
  }

  Widget _worksPane(List<Product> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: OudSectionCard(
          child: Center(
            child: Text(
              '표시할 스토리가 없습니다.',
              style: TextStyle(color: OudColors.mutedText),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, index) {
        final product = products[index];
        return SizedBox(
          width: 170,
          child: OudSectionCard(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: OudRadii.md,
                  child: AspectRatio(
                    aspectRatio: 1.1,
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
                const SizedBox(height: 8),
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reviewPane(UserDataManager manager) {
    final count = manager.reviewCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: OudSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '누적 리뷰 ${count}건',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              '수공예 질감과 안정적인 형태, 패키징 완성도에 대한 긍정적인 평가가 많습니다.',
              style: TextStyle(color: OudColors.mutedText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _postCard(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: OudSectionCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: OudColors.surface,
              radius: 20,
              child: Text(
                product.title.isEmpty ? 'O' : product.title.substring(0, 1),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OUD', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    '${product.title} 작업 스케치를 업로드했습니다.',
                    style: const TextStyle(color: OudColors.mutedText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
