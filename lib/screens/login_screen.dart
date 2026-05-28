import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data_manager.dart';
import 'signup_screen.dart';

// 로그인 화면: 이메일/비밀번호로 로그인하고, 실패 시 즉시 에러를 보여준다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberEmail = false;
  bool _autoLogin = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('rememberEmail') ?? false;
    final savedEmail = prefs.getString('savedEmail') ?? '';
    final autoLogin = prefs.getBool('autoLoginEnabled') ?? true;
    if (!mounted) return;
    setState(() {
      _rememberEmail = remember;
      _autoLogin = autoLogin;
      if (remember && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
    });
  }

  Future<void> _savePrefs({required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberEmail', _rememberEmail);
    await prefs.setBool('autoLoginEnabled', _autoLogin);
    if (_rememberEmail) {
      await prefs.setString('savedEmail', email);
    } else {
      await prefs.remove('savedEmail');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _messageForAuthCode(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'user-not-found':
        return '가입되지 않은 계정입니다. 회원가입 후 이용해주세요.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'operation-not-allowed':
        return '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
      case 'too-many-requests':
        return '요청이 많습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '로그인에 실패했습니다. ($code)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '다시 만나 반가워요',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _rememberEmail,
              onChanged: (value) async {
                setState(() => _rememberEmail = value ?? false);
                await _savePrefs(email: _emailController.text.trim());
              },
              title: const Text('아이디 저장'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _autoLogin,
              onChanged: (value) async {
                setState(() => _autoLogin = value ?? true);
                await _savePrefs(email: _emailController.text.trim());
              },
              title: const Text('자동 로그인'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final manager = context.read<UserDataManager>();
                final navigator = Navigator.of(context);
                final email = _emailController.text.trim();
                final password = _passwordController.text;

                if (email.isEmpty || password.isEmpty) {
                  _showMessage('이메일과 비밀번호를 입력해주세요.');
                  return;
                }

                try {
                  await manager.login(email: email, password: password);
                  await _savePrefs(email: email);
                  if (!mounted) return;
                  navigator.pop();
                } on FirebaseAuthException catch (e) {
                  if (!mounted) return;
                  final detail = e.message ?? e.code;
                  _showMessage('로그인 실패: ${_messageForAuthCode(e.code)} ($detail)');
                } on FirebaseException catch (e) {
                  if (!mounted) return;
                  final detail = e.message ?? e.code;
                  _showMessage('로그인 실패: $detail');
                } catch (e) {
                  if (!mounted) return;
                  _showMessage('로그인 실패: ${e.toString()}');
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFA53C2C),
              ),
              child: const Text('로그인',
                  style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text('계정이 없으신가요? 회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
