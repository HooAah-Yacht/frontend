import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/main_screen.dart' show MainScreen, mainScreenKey;
import 'package:frontend/screens/notice_screen.dart';
import 'package:frontend/screens/sign_in_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/yacht/invite_accept_dialog.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';
import 'package:frontend/services/yacht_service.dart';
import 'package:frontend/screens/main_screen.dart' show mainScreenKey;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// RouteObserver를 전역으로 선언
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // Kakao SDK 초기화
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '', // .env에서 불러오기
  );

  // 앱 실행
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// 딥링크 처리를 위한 전역 변수
_MyAppState? _appStateInstance;

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appStateInstance = this;
    _appLinks = AppLinks();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    if (_appStateInstance == this) {
      _appStateInstance = null;
    }
    super.dispose();
  }

  void _initDeepLinkListener() {
    // 앱이 실행 중일 때 딥링크 수신
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri.toString());
      },
      onError: (err) {
        print('딥링크 오류: $err');
      },
    );

    // 앱이 종료된 상태에서 딥링크로 실행된 경우
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri.toString());
      }
    });
  }

  void _handleDeepLink(String link) {
    print('딥링크 수신: $link');
    
    // URL 파싱: hooaah://invite?code=123
    try {
      final uri = Uri.parse(link);
      if (uri.scheme == 'hooaah' && uri.host == 'invite') {
        final codeStr = uri.queryParameters['code'];
        if (codeStr != null) {
          final code = int.tryParse(codeStr);
          if (code != null) {
            _showInviteDialog(code);
          } else {
            print('초대 코드 파싱 실패: $codeStr');
          }
        } else {
          print('초대 코드가 없습니다.');
        }
      }
    } catch (e) {
      print('딥링크 파싱 오류: $e');
    }
  }

  void _showInviteDialog(int code) {
    // Navigator가 준비될 때까지 대기
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = navigatorKey.currentContext;
      if (context != null) {
        InviteAcceptDialog.show(
          context,
          inviteCode: code,
          onAccept: () async {
            // 초대 수락 API 호출
            final result = await YachtService.acceptInvite(code);
            
            if (context.mounted) {
              if (result['success']) {
                // 요트 리스트 새로고침
                final mainScreenState = mainScreenKey.currentState;
                if (mainScreenState != null) {
                  mainScreenState.refreshYachtList();
                }
                
                CustomSnackBar.showSuccess(
                  context,
                  message: '초대를 수락했습니다.',
                );
              } else {
                CustomSnackBar.showError(
                  context,
                  message: result['message'] as String? ?? '초대 수락에 실패했습니다.',
                );
              }
            }
          },
          onReject: () {
            // 거절 처리 - 다이얼로그만 닫힘
            if (context.mounted) {
              CustomSnackBar.show(
                context,
                message: '초대를 거절했습니다.',
              );
            }
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hooaah',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
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
        '/home': (context) => MainScreen(key: mainScreenKey),
        '/notice': (context) => const NoticeScreen(),
        '/settings': (context) => const SettingsScreen(),
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
