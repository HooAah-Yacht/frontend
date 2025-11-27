import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/main_screen.dart' show MainScreen, getMainScreenState;
import 'package:frontend/screens/notice_screen.dart';
import 'package:frontend/screens/sign_in_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/yacht/invite_accept_dialog.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';
import 'package:frontend/services/yacht_service.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

// Local Notifications 플러그인 초기화
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 백그라운드 메시지 핸들러 (최상위 함수로 선언해야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('백그라운드 메시지 수신: ${message.messageId}');
  print('메시지 데이터: ${message.data}');
  print('메시지 알림: ${message.notification?.title}');
  
  // 백그라운드에서도 알림 표시
  await _showBackgroundNotification(message);
}

// 백그라운드 알림 표시 함수 (최상위 함수로 선언)
@pragma('vm:entry-point')
Future<void> _showBackgroundNotification(RemoteMessage message) async {
  // Local Notifications 초기화 (백그라운드에서도 필요)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();
  
  await localNotifications.initialize(initializationSettings);

  // Android 알림 채널 생성
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 알림 표시
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await localNotifications.show(
    message.hashCode,
    message.notification?.title ?? '알림',
    message.notification?.body ?? '새 메시지가 도착했습니다.',
    platformChannelSpecifics,
    payload: message.data.toString(),
  );
}
// RouteObserver를 전역으로 선언
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Local Notifications 초기화 함수
Future<void> _initializeLocalNotifications() async {
  // Android 초기화 설정
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS 초기화 설정 (Android만 사용하므로 빈 설정)
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  // Android 알림 채널 생성
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // AndroidManifest.xml에서 설정한 채널 ID와 동일
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> main() async {
  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // Kakao SDK 초기화
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '', // .env에서 불러오기
  );

  // Firebase 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Local Notifications 초기화
  await _initializeLocalNotifications();

  // FCM 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
    _initFirebaseMessaging();
  }

  // FCM 초기화 및 설정
  void _initFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // 알림 권한 요청 (Android 13 이상)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('알림 권한 상태: ${settings.authorizationStatus}');

    // FCM 토큰 가져오기
    String? token = await messaging.getToken();
    print('========================================');
    print('FCM 토큰 (Firebase Console에서 사용):');
    print(token ?? '토큰을 가져올 수 없습니다');
    print('========================================');

    // 토큰 갱신 리스너
    messaging.onTokenRefresh.listen((newToken) {
      print('FCM 토큰 갱신: $newToken');
      // 여기서 서버에 새 토큰을 업데이트할 수 있습니다
    });

    // 포그라운드 메시지 처리 (앱이 열려있을 때)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('포그라운드 메시지 수신: ${message.messageId}');
      print('메시지 데이터: ${message.data}');
      print('메시지 알림: ${message.notification?.title}');
      print('메시지 본문: ${message.notification?.body}');
      
      // 포그라운드에서 알림 표시
      _showNotification(message);
    });

    // 백그라운드에서 알림 탭 처리 (앱이 백그라운드에 있을 때)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('백그라운드에서 알림 탭: ${message.messageId}');
      print('메시지 데이터: ${message.data}');
      _handleNotificationTap(message);
    });

    // 앱이 종료된 상태에서 알림으로 열린 경우 처리
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print('종료 상태에서 알림으로 앱 열림: ${initialMessage.messageId}');
      _handleNotificationTap(initialMessage);
    }
  }

  // 알림 탭 처리
  void _handleNotificationTap(RemoteMessage message) {
    // 메시지 데이터에 따라 적절한 화면으로 이동
    // 예: 알림 화면으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // 알림 화면으로 이동하거나 다른 작업 수행
        Navigator.of(context).pushNamed('/notice');
      }
    });
  }

  // 포그라운드 알림 표시 함수
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // AndroidManifest.xml에서 설정한 채널 ID와 동일
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode, // 알림 ID (고유해야 함)
      message.notification?.title ?? '알림',
      message.notification?.body ?? '새 메시지가 도착했습니다.',
      platformChannelSpecifics,
      payload: message.data.toString(), // 알림 탭 시 전달할 데이터
    );
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
                final mainScreenState = getMainScreenState();
                if (mainScreenState != null && mainScreenState.mounted) {
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
        '/home': (context) => const MainScreen(),
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
