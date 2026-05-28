import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';

class ReviewManageScreen extends StatelessWidget {
  const ReviewManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final reviewCandidates = manager.purchasedProducts
        .where((product) => !manager.hasReview(product.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(title: const Text('리뷰 관리'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '작성 가능한 리뷰',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF303330),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '배송이 끝난 작품에 리뷰를 남기고 마일리지를 받아보세요.',
              style: TextStyle(color: Color(0xFF5D605C)),
            ),
            const SizedBox(height: 24),
            if (reviewCandidates.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: Text('작성 가능한 리뷰가 없습니다.')),
              )
            else
              ...reviewCandidates.map(
                (product) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: product.image != null
                            ? Image.asset(
                                product.image!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 88,
                                  height: 88,
                                  color: const Color(0xFFEEEEEA),
                                ),
                              )
                            : Container(
                                width: 88,
                                height: 88,
                                color: const Color(0xFFEEEEEA),
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HANDMADE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: Color(0xFF4E663B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF303330),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '배송 완료 상품',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5D605C),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: Color(0xFF645884),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '+500P',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF645884),
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('마이페이지 구매 탭에서 리뷰를 작성할 수 있습니다.'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDEFAC3),
                                    foregroundColor: const Color(0xFF496137),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: const Text('Write Review'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
