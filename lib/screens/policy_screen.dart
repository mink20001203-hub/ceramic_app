import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final items = manager.policyArticles;
    final format = DateFormat('yyyy.MM.dd');

    return Scaffold(
      appBar: AppBar(title: const Text('약관 및 정책')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        itemCount: items.length,
        itemBuilder: (_, index) {
          final item = items[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: OudRadii.lg,
              border: Border.all(color: OudColors.border),
            ),
            child: ExpansionTile(
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${item.summary}\n업데이트: ${format.format(item.updatedAt)}',
                style: const TextStyle(color: OudColors.mutedText, height: 1.35),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.content,
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
