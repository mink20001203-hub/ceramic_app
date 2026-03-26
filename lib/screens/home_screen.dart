import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_data_manager.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = '전체';
  String _sortOption = '최신순';

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final products = manager.products;

    final filteredProducts = _selectedCategory == '전체'
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();
    final sortedProducts = _applySort(filteredProducts);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _topSection(context)),
          SliverToBoxAdapter(child: _categorySection(products)),
          SliverToBoxAdapter(child: _sortRow()),
          SliverToBoxAdapter(child: _bannerSection(context)),
          SliverToBoxAdapter(
            child: _sectionHeader('오늘의 추천', '오늘 분위기에 어울리는 작품'),
          ),
          SliverToBoxAdapter(child: _horizontalList(sortedProducts)),
          SliverToBoxAdapter(
            child: _sectionHeader('신상 도착', '방금 들어온 신상 라인'),
          ),
          SliverToBoxAdapter(child: _newGrid(sortedProducts)),
          SliverToBoxAdapter(
            child: _sectionHeader('전체 상품', '마음에 드는 작품을 골라보세요'),
          ),
          if (manager.productsLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else
            _allGrid(sortedProducts),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  List<Product> _applySort(List<Product> products) {
    final sorted = List<Product>.from(products);
    switch (_sortOption) {
      case '가격 낮은순':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case '가격 높은순':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case '인기순':
        sorted.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      default:
        break;
    }
    return sorted;
  }

  Widget _topSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'OUD',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFA53C2C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '도자기 크리에이터 마켓',
                  style: TextStyle(color: Color(0xFFA53C2C), fontSize: 12),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '오늘은 어떤 감도의 도자기를 찾으세요?',
            style: TextStyle(color: Color(0xFF5D605C)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0DFDA)),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Color(0xFF8B8B86)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '작품, 작가, 키워드로 검색',
                    style: TextStyle(color: Color(0xFF8B8B86)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categorySection(List<Product> products) {
    final categorySet = products.map((p) => p.category).toSet().toList();
    categorySet.sort();
    final categories = ['전체', ...categorySet];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final label = categories[index];
            final selected = _selectedCategory == label;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = label;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFA53C2C)
                      : const Color(0xFFF4F4F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF5D605C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sortRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.tune, size: 18, color: Color(0xFF5D605C)),
          const SizedBox(width: 6),
          const Text('정렬', style: TextStyle(color: Color(0xFF5D605C))),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '최신순', child: Text('최신순')),
              const PopupMenuItem(value: '인기순', child: Text('인기순')),
              const PopupMenuItem(value: '가격 낮은순', child: Text('가격 낮은순')),
              const PopupMenuItem(value: '가격 높은순', child: Text('가격 높은순')),
            ],
            child: Row(
              children: [
                Text(
                  _sortOption,
                  style: const TextStyle(
                    color: Color(0xFF5D605C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, color: Color(0xFF5D605C)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  'assets/images/stitch_home.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF4E6E2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '이번 주 드롭',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'OUD 크리에이터 8종 라인 공개',
                          style: TextStyle(color: Color(0xFF5D605C)),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFA53C2C)),
                          ),
                          child: const Text('드롭 보기'),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/mug.jpg',
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF5D605C))),
        ],
      ),
    );
  }

  Widget _horizontalList(List<Product> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: Text('추천 상품이 없습니다.')),
      );
    }
    final slice = products.take(6).toList();
    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final product = slice[index];
          return SizedBox(width: 160, child: ProductCard(product: product));
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: slice.length,
      ),
    );
  }

  Widget _newGrid(List<Product> products) {
    final newItems = products.where((p) => p.isNew).take(4).toList();
    if (newItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: newItems.length,
        itemBuilder: (context, index) {
          return ProductCard(product: newItems[index]);
        },
      ),
    );
  }

  Widget _allGrid(List<Product> products) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text('표시할 상품이 없습니다.')),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ProductCard(product: products[index]);
          },
          childCount: products.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      ),
    );
  }
}
