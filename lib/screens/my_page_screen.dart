// lib/my_page_screen.dart 파일

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data_manager.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚨 UserDataManager에서 데이터 읽기
    final userData = Provider.of<UserDataManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 요약 대시보드
            _buildSummaryCard(userData),
            const SizedBox(height: 24),

            // 2. 구매 기록 목록
            const Text(
              '최근 구매 기록',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPurchaseList(userData),

            // 3. 테스트 버튼 (구매 기록 추가)
            ElevatedButton(
              onPressed: () {
                userData.addPurchase(
                  PurchaseRecord(
                    title: '테스트 구매 - 새 상품',
                    price: 40000,
                    date: DateTime.now(),
                  ),
                );
              },
              child: const Text('테스트 구매 추가 (마일리지 적립)'),
            ),
          ],
        ),
      ),
    );
  }

  // 마일리지, 쿠폰, 후기 수 요약 카드 위젯
  Widget _buildSummaryCard(UserDataManager userData) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('마일리지', '${userData.mileage} P'),
            _buildSummaryItem('쿠폰', '0 개'),
            _buildSummaryItem('후기 수', '${userData.reviewCount} 건'),
          ],
        ),
      ),
    );
  }

  // 요약 항목 단일 위젯
  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 구매 기록 목록 위젯
  Widget _buildPurchaseList(UserDataManager userData) {
    if (userData.purchaseRecords.isEmpty) {
      return const Text('아직 구매 기록이 없습니다.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userData.purchaseRecords.length,
      itemBuilder: (context, index) {
        final record = userData.purchaseRecords[index];
        return ListTile(
          title: Text(record.title),
          subtitle: Text(
              '${record.date.year}.${record.date.month}.${record.date.day} 구매'),
          trailing: Text('${record.price} 원'),
        );
      },
    );
  }
}
