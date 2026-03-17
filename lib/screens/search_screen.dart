import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

// 검색 화면: 더미 상품 목록에서 제목 기준으로 필터링한다.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // 검색어 저장 변수
  String _searchQuery = '';

  // 검색 결과 리스트 (초기값은 빈 리스트)
  List<Product> _searchResults = [];

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
      if (_searchQuery.isEmpty) {
        _searchResults = [];
      } else {
        // 상품 목록에서 제목(title)에 검색어가 포함된 것만 필터링
        _searchResults = dummyProducts
            .where((product) => product.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 검색창 UI
        title: TextField(
          autofocus: true, // 화면 들어오자마자 키보드 올리기
          decoration: const InputDecoration(
            hintText: '찾으시는 도자기를 검색하세요',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(fontSize: 18),
          onChanged: _updateSearchQuery, // 글자 바뀔 때마다 검색 실행
        ),
      ),
      body: _searchQuery.isEmpty
          ? const Center(child: Text('검색어를 입력해 주세요.'))
          : _searchResults.isEmpty
              ? const Center(child: Text('검색 결과가 없습니다.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) =>
                      ProductCard(product: _searchResults[index]),
                ),
    );
  }
}
