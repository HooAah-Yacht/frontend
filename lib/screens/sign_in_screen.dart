import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/custom_snackbar.dart';
import '../widgets/signin/signin_button.dart';
import '../widgets/signin/signin_input_fields.dart';
import '../widgets/signin/signin_login_link.dart';
import '../widgets/signin/signin_title.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isEmailVerified = false; // 이메일 중복확인 여부
  bool _isButtonEnabled = false; // 회원가입 버튼 활성화 여부
  bool _isEmailChecking = false;
  bool _isSubmitting = false;
  String? _verifiedEmail;
  String? _emailStatusMessage;
  Color? _emailStatusColor;

  @override
  void initState() {
    super.initState();
    // 텍스트 필드 변경 리스너 추가
    _nameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 버튼 활성화 상태 업데이트
  void _updateButtonState() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      if (_verifiedEmail != null && email != _verifiedEmail) {
        _isEmailVerified = false;
        _verifiedEmail = null;
        _emailStatusMessage = null;
        _emailStatusColor = null;
      }
      _isButtonEnabled = name.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          confirmPassword.isNotEmpty &&
          _isEmailVerified;
    });
  }

  // 비밀번호 유효성 검사 (6-20자, 영문 소문자, 특수문자 조합)
  bool _isPasswordValid(String password) {
    if (password.length < 6 || password.length > 20) {
      return false;
    }
    // 영문 소문자 포함 확인
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    // 특수문자 포함 확인
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasLowercase && hasSpecialChar;
  }

  // 이메일 중복확인 API 호출 함수 (나중에 구현)
  Future<void> _checkEmailDuplicate() async {
    if (_isEmailChecking) return;

    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      CustomSnackBar.showError(
        context,
        message: '이메일을 입력해주세요.',
      );
      return;
    }

    final bool isValidEmail = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);

    if (!isValidEmail) {
      CustomSnackBar.showError(
        context,
        message: '올바른 이메일 형식이 아닙니다.',
      );
      return;
    }

    setState(() {
      _isEmailChecking = true;
      _emailStatusMessage = null;
      _emailStatusColor = null;
    });

    final result = await AuthService.checkEmailDuplicate(email);

    if (!mounted) return;

    final bool success = result['success'] == true;
    final bool isDuplicate = result['isDuplicate'] == true;
    final String message =
        result['message'] as String? ?? '이메일 확인에 실패했습니다.';

    setState(() {
      _isEmailChecking = false;
      if (success && !isDuplicate) {
        _isEmailVerified = true;
        _verifiedEmail = email;
        _emailStatusMessage = '사용 가능한 이메일입니다.';
        _emailStatusColor = Colors.green;
      } else if (success && isDuplicate) {
        _isEmailVerified = false;
        _verifiedEmail = null;
        _emailStatusMessage = '이미 사용 중인 이메일입니다.';
        _emailStatusColor = Colors.red;
      } else {
        _isEmailVerified = false;
        _verifiedEmail = null;
        _emailStatusMessage = message;
        _emailStatusColor = Colors.red;
      }
      _isButtonEnabled = _nameController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty &&
          _confirmPasswordController.text.trim().isNotEmpty &&
          _isEmailVerified;
    });

    if (success && !isDuplicate) {
      CustomSnackBar.showSuccess(
        context,
        message: '사용 가능한 이메일입니다.',
      );
    } else {
      CustomSnackBar.showError(
        context,
        message: success && isDuplicate
            ? '이미 사용 중인 이메일입니다.'
            : message,
      );
    }
  }

  // 회원가입 버튼 클릭 함수
  Future<void> _handleSignUp() async {
    if (_isSubmitting) return;

    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 비밀번호 유효성 검사
    if (!_isPasswordValid(password)) {
      CustomSnackBar.showError(
        context,
        message: '비밀번호가 양식에 맞지 않습니다.',
      );
      return;
    }

    // 비밀번호 확인 검사
    if (password != confirmPassword) {
      CustomSnackBar.showError(
        context,
        message: '비밀번호 확인란과 비밀번호 란이 일치하지 않습니다.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await AuthService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result['success'] == true) {
      CustomSnackBar.showSuccess(
        context,
        message: '회원가입이 완료되었습니다. 로그인해주세요.',
      );
      Navigator.pop(context);
    } else {
      final String message =
          result['message'] as String? ?? '회원가입에 실패했습니다.';
      CustomSnackBar.showError(
        context,
        message: message,
      );
    }
  }

  // 로그인 페이지로 이동
  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '회원가입',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const SignInTitle(),
                const SizedBox(height: 32),
                
                // 입력 필드들
                SignInInputFields(
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  onEmailDuplicateCheck: () => _checkEmailDuplicate(),
                  isEmailVerified: _isEmailVerified,
                  isEmailChecking: _isEmailChecking,
                  emailStatusMessage: _emailStatusMessage,
                  emailStatusColor: _emailStatusColor,
                ),
                const SizedBox(height: 32),

                // 회원가입 버튼
                SignInButton(
                  onPressed: _isButtonEnabled && !_isSubmitting
                      ? () => _handleSignUp()
                      : () {},
                  isEnabled: _isButtonEnabled && !_isSubmitting,
                ),
                const SizedBox(height: 24),

                // 로그인 링크
                SignInLoginLink(
                  onPressed: _navigateToLogin,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

