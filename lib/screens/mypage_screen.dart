import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataManager>(context);
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 정보
            Row(
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person)),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userData.userName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(userData.userEmail,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 활동 정보 (마일리지, 리뷰)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    '마일리지', '${priceFormat.format(userData.mileage)}P'),
                _buildStatItem('리뷰', '${userData.reviewCount}개'),
              ],
            ),
            const Divider(height: 40),

            const Text('최근 구매 기록',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // 구매 리스트
            userData.purchaseRecords.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('구매 내역이 없습니다.'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userData.purchaseRecords.length,
                    itemBuilder: (context, index) {
                      final record = userData.purchaseRecords[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(record.title),
                        subtitle:
                            Text(DateFormat('yyyy-MM-dd').format(record.date)),
                        trailing: Text('${priceFormat.format(record.price)}원'),
                      );
                    },
                  ),

            const SizedBox(height: 20),

            // 테스트 버튼 (구매 기록 추가 확인용)
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
