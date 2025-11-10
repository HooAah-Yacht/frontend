import 'package:flutter/material.dart';
import 'package:frontend/widgets/auth/auth_logo.dart';
import 'package:frontend/widgets/auth/auth_input_fields.dart';
import 'package:frontend/widgets/auth/forgot_password_link.dart';
import 'package:frontend/widgets/auth/auth_login_button.dart';
import 'package:frontend/widgets/auth/signup_link.dart';
import 'package:frontend/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async { 
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 이메일 유효성 검사
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 비밀번호 유효성 검사
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호를 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('API 호출 시작\n');

    // 로그인 API 호출
    final result = await AuthService.login(email, password);

    print('API 응답 결과: $result');

    if (!mounted) return;

    if (result['success'] == true) {
      // 로그인 성공
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // 로그인 실패
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? '로그인에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                const AuthLogo(),
                const SizedBox(height: 80),
                // Input Fields
                AuthInputFields(
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
                const SizedBox(height: 24),
                // Forgot Password
                ForgotPasswordLink(
                  onTap: () {
                    // TODO: Navigate to forgot password page
                  },
                ),
                const SizedBox(height: 40),
                // Login Button
                AuthLoginButton(
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),
                // Sign Up Link
                SignUpLink(
                  onTap: () {
                    Navigator.of(context).pushNamed('/signin');
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
