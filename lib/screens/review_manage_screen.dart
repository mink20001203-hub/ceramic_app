import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data_manager.dart';

// 작성한 리뷰를 관리하는 화면
class ReviewManageScreen extends StatelessWidget {
  const ReviewManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('내 리뷰 관리'), centerTitle: true),
      body: manager.reviews.isEmpty
          ? const Center(child: Text('작성한 리뷰가 없습니다.'))
          : ListView.builder(
              itemCount: manager.reviews.length,
              itemBuilder: (context, index) {
                final review = manager.reviews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(review.productName),
                    subtitle: Text(review.comment,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        manager.removeReviewAt(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('리뷰가 삭제되었습니다.')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
