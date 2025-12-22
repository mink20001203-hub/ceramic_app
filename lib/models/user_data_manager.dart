import 'package:flutter/material.dart';

// 구매 기록을 저장하기 위한 클래스
class PurchaseRecord {
  final String title;
  final int price;
  final DateTime date;

  PurchaseRecord(
      {required this.title, required this.price, required this.date});
}

class UserDataManager with ChangeNotifier {
  String _userName = '도자기 팬';
  String _userEmail = 'ceramic_lover@example.com';
  int _mileage = 1500; // 마일리지 추가
  int _reviewCount = 5; // 리뷰 수 추가

  // 구매 기록 리스트
  List<PurchaseRecord> _purchaseRecords = [];

  // Getter들
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get mileage => _mileage;
  int get reviewCount => _reviewCount;
  List<PurchaseRecord> get purchaseRecords => _purchaseRecords;

  // 구매 기록 추가 함수
  void addPurchase(PurchaseRecord record) {
    _purchaseRecords.insert(0, record); // 최신순으로 추가
    _mileage += (record.price * 0.01).toInt(); // 구매 금액의 1% 적립
    notifyListeners();
  }

  void updateUser(String name, String email) {
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }
}
