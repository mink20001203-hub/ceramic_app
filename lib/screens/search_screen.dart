// lib/search_screen.dart 파일 전체 코드 (StatefulWidget 전환 및 검색 기능 틀)
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchResults = dummyProducts; // 초기값 설정
    _searchController.addListener(_filterResults);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterResults);
    _searchController.dispose();
    super.dispose();
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _searchResults = dummyProducts;
      });
      return;
    }

    setState(() {
      _searchResults = dummyProducts.where((product) {
        final titleLower = product.title.toLowerCase();
        final subTitleLower = product.subTitle.toLowerCase();
        return titleLower.contains(query) || subTitleLower.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // 웹 환경을 고려하여 열 개수 조절
    final int crossAxisCount =
        screenWidth > 1200 ? 4 : (screenWidth > 800 ? 3 : 2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '찾으시는 도자기가 있나요?',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              // 🚨 검색어 한 번에 지우기 버튼 추가
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onSubmitted: (value) => _filterResults(),
          ),
        ),
      ),
      body: _searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "'${_searchController.text}'\n에 대한 검색 결과가 없습니다.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _searchResults.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                // ✅ 이미지와 텍스트가 조화롭게 보이도록 비율 수정
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return ProductCard(product: _searchResults[index]);
              },
            ),
    );
  }
}
