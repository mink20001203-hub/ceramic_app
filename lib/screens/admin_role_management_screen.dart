import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';

class AdminRoleManagementScreen extends StatefulWidget {
  const AdminRoleManagementScreen({super.key});

  @override
  State<AdminRoleManagementScreen> createState() =>
      _AdminRoleManagementScreenState();
}

class _AdminRoleManagementScreenState extends State<AdminRoleManagementScreen> {
  bool _loading = true;
  List<AdminUserSummary> _users = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final manager = context.read<UserDataManager>();
    setState(() => _loading = true);
    final users = await manager.loadUsersForAdmin();
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    if (!manager.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('판매자 권한 관리')),
        body: const Center(
          child: Text('관리자만 접근할 수 있습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('판매자 권한 관리'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('사용자 데이터가 없습니다.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemBuilder: (_, index) {
                    final user = _users[index];
                    return _UserRoleTile(
                      user: user,
                      onChanged: (nextRole) async {
                        if (nextRole == null || nextRole == user.role) return;
                        final messenger = ScaffoldMessenger.of(context);
                        await manager.updateUserRoleByAdmin(
                          targetUserId: user.id,
                          role: nextRole,
                        );
                        await _reload();
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('${user.userName} 권한을 변경했습니다.'),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: _users.length,
                ),
    );
  }
}

class _UserRoleTile extends StatelessWidget {
  final AdminUserSummary user;
  final ValueChanged<UserRole?> onChanged;

  const _UserRoleTile({
    required this.user,
    required this.onChanged,
  });

  static const Map<UserRole, String> _labels = {
    UserRole.user: 'user',
    UserRole.seller: 'seller',
    UserRole.admin: 'admin',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email.isEmpty ? user.id : user.email,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<UserRole>(
            value: user.role,
            items: UserRole.values
                .map(
                  (role) => DropdownMenuItem<UserRole>(
                    value: role,
                    child: Text(_labels[role] ?? 'user'),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
