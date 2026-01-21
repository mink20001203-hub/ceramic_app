import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data_manager.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isAgreed = false; // 약관 동의 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '새로운 계정을\n만들어보세요!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // 이름(닉네임) 입력
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: '이름', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // 이메일 입력
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: '이메일', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // 비밀번호 입력
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: '비밀번호', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // 비밀번호 확인
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: '비밀번호 확인', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // 이용약관 동의 체크박스
            CheckboxListTile(
              title: const Text('이용약관 및 개인정보 처리방침에 동의합니다.'),
              value: _isAgreed,
              onChanged: (value) => setState(() => _isAgreed = value!),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 20),

            // 가입하기 버튼
            ElevatedButton(
              onPressed: _isAgreed
                  ? () {
                      // 1. 필수 정보 입력 확인
                      if (_nameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('모든 정보를 입력해주세요.')),
                        );
                        return;
                      }

                      // 2. 비밀번호 일치 확인
                      if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                        );
                        return;
                      }

                      // 3. 모든 검증 통과 시 이름 저장 및 가입 완료 처리
                      Provider.of<UserDataManager>(context, listen: false)
                          .setUserName(_nameController.text);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('회원가입이 완료되었습니다! 로그인을 진행해주세요.')),
                      );

                      Navigator.pop(context); // 가입 완료 후 로그인 창으로 돌아가기
                    }
                  : null, // 약관 동의 안 하면 버튼 비활성화
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('가입 완료',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
