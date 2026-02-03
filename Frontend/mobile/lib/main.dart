import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/config/routes.dart';
import 'providers/auth_provider.dart';
import 'app_state_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/student/create_profile_screen.dart';
import 'screens/main_screen.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path URL strategy for web (removes # from URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) {
          final appState = AppStateProvider();
          appState.initialize();
          return appState;
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        // On mobile (Android/iOS) show the native mobile MainScreen directly.
        if (!kIsWeb) {
          return MaterialApp(
            title: 'PFE Match',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              useMaterial3: true,
            ),
            home: const MainScreen(),
          );
        }

        // For web, keep the routed app (auth + web flows)
        return MaterialApp(
          title: 'PFE Match',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.login,
          onGenerateRoute: _generateRoute,
        );
      },
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case '/':
      case '/login':
        page = const LoginScreen();
        break;
      case '/register':
        page = const RegisterScreen();
        break;
      case '/home':
        page = const HomeScreen();
        break;
      case '/create-student-profile':
        page = const CreateStudentProfileScreen();
        break;
      default:
        page = const LoginScreen();
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
