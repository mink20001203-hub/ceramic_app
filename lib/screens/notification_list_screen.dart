import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final items = manager.notifications;
    final format = DateFormat('M/d HH:mm', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          TextButton(
            onPressed: items.isEmpty ? null : manager.markAllNotificationsAsRead,
            child: const Text('전체 읽음'),
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                '표시할 알림이 없습니다.',
                style: TextStyle(color: OudColors.mutedText),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = items[index];
                final read = manager.isNotificationRead(item.id);
                return InkWell(
                  borderRadius: OudRadii.md,
                  onTap: () => manager.markNotificationAsRead(item.id),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: read ? Colors.white : const Color(0xFFF8F3EC),
                      borderRadius: OudRadii.md,
                      border: Border.all(
                        color: read ? OudColors.border : const Color(0xFFE9D4CB),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: read ? FontWeight.w700 : FontWeight.w900,
                                ),
                              ),
                            ),
                            if (!read)
                              const Icon(Icons.circle, size: 8, color: OudColors.primary),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(item.body, style: const TextStyle(height: 1.35)),
                        const SizedBox(height: 6),
                        Text(
                          format.format(item.createdAt),
                          style: const TextStyle(
                            color: OudColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
