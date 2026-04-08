import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data_manager.dart';

// 회원가입 화면: 입력값을 확인하고 Firebase Auth 계정을 생성한다.
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _messageForAuthCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '이미 가입된 이메일입니다.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'weak-password':
        return '비밀번호는 6자리 이상이어야 합니다.';
      case 'operation-not-allowed':
        return '이메일/비밀번호 회원가입이 비활성화되어 있습니다.';
      default:
        return '회원가입에 실패했습니다. ($code)';
    }
  }

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
              '새로운 계정을 만들어보세요!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // 이름(닉네임) 입력
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 이메일 입력
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // 비밀번호 입력
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 비밀번호 확인
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 이용약관 동의 체크박스
            CheckboxListTile(
              title: const Text('이용약관 및 개인정보 처리방침에 동의합니다.'),
              value: _isAgreed,
              onChanged: (value) => setState(() => _isAgreed = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 20),

            // 가입하기 버튼
            ElevatedButton(
              onPressed: _isAgreed
                  ? () async {
                      final manager = context.read<UserDataManager>();
                      final navigator = Navigator.of(context);
                      final name = _nameController.text.trim();
                      final email = _emailController.text.trim();
                      final password = _passwordController.text;
                      final confirm = _confirmPasswordController.text;

                      if (name.isEmpty || email.isEmpty || password.isEmpty) {
                        _showMessage('모든 정보를 입력해주세요.');
                        return;
                      }

                      if (password.length < 6) {
                        _showMessage('비밀번호는 6자리 이상이어야 합니다.');
                        return;
                      }

                      if (password != confirm) {
                        _showMessage('비밀번호가 일치하지 않습니다.');
                        return;
                      }

                      try {
                        await manager.register(
                          email: email,
                          password: password,
                          name: name,
                        );

                        _showMessage('회원가입이 완료되었습니다! 로그인해주세요.');
                        if (!mounted) return;
                        navigator.pop();
                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;
                        _showMessage('회원가입 실패: ${_messageForAuthCode(e.code)}');
                      } catch (_) {
                        if (!mounted) return;
                        _showMessage('회원가입에 실패했습니다.');
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA53C2C),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '가입하기',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


