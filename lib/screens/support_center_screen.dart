import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final faqs = manager.supportFaqs;

    return Scaffold(
      appBar: AppBar(title: const Text('고객센터')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F3EC),
              borderRadius: OudRadii.md,
              border: Border.all(color: OudColors.border),
            ),
            padding: const EdgeInsets.all(12),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '문의 채널',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                SizedBox(height: 6),
                Text('이메일: support@oud.app'),
                Text('운영시간: 평일 10:00 ~ 18:00'),
                Text('점심시간: 12:30 ~ 13:30'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '자주 묻는 질문',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...faqs.map(
            (faq) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(faq.question),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faq.answer,
                      style: const TextStyle(color: OudColors.mutedText, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
