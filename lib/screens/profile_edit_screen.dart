import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    if (!_initialized) {
      _initialized = true;
      _nameController.text = manager.userName;
      _phoneController.text = manager.profilePhone;
      _bioController.text = manager.profileBio;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 편집')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '계정 정보',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '이름'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return '이름을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: '연락처',
                    hintText: '010-1234-5678',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: '소개글',
                    hintText: '브랜드/작가 소개, 응답 시간, 작업 스타일을 입력하세요.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F3EC),
              borderRadius: OudRadii.md,
              border: Border.all(color: OudColors.border),
            ),
            padding: const EdgeInsets.all(12),
            child: const Text(
              '저장하면 Firestore users/{uid} 문서에 profile 필드가 반영됩니다.',
              style: TextStyle(color: OudColors.mutedText),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _saving = true);
                      try {
                        await context.read<UserDataManager>().updateProfile(
                              name: _nameController.text,
                              phone: _phoneController.text,
                              bio: _bioController.text,
                            );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('프로필이 저장되었습니다.')),
                        );
                        Navigator.pop(context);
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              child: Text(_saving ? '저장 중...' : '저장하기'),
            ),
          ),
        ],
      ),
    );
  }
}
