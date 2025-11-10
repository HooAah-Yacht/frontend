import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/notice_screen.dart';
import 'package:frontend/screens/sign_in_screen.dart';
import 'package:frontend/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hooaah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSans',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E5090)),
        useMaterial3: true,
      ),
      // Named routes 설정
      routes: {
        '/': (context) => const AuthInitializer(),
        '/login': (context) => const LoginScreen(),
        '/signin': (context) => const SignInScreen(),
        '/home': (context) => const HomeScreen(),
        '/notice': (context) => const NoticeScreen(),
      },
      initialRoute: '/',
    );
  }
}

// 초기 화면을 결정하는 위젯
class AuthInitializer extends StatelessWidget {
  const AuthInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2B4184),
              ),
            ),
          );
        }

        // 토큰 체크 완료 후 적절한 화면으로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (snapshot.data == true) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });

        // 네비게이션 전까지 로딩 화면 표시
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2B4184),
            ),
          ),
        );
      },
    );
  }
}
