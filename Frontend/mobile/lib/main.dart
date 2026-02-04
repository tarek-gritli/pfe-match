import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/config/routes.dart';
import 'providers/auth_provider.dart';
import 'app_state_provider.dart';
import 'Screens/auth/login_screen.dart';
import 'Screens/auth/register_screen.dart';
import 'Screens/home/home_screen.dart';
import 'Screens/Student/create_profile_screen.dart';
import 'Screens/Student/edit_profile_screen.dart';
import 'Screens/Enterprise/create_profile_screen.dart';
import 'Screens/Main_screen.dart';
import 'Screens/Enterprise_main_screen.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    return Consumer2<AppStateProvider, AuthProvider>(
      builder: (context, appState, authProvider, child) {
        // On mobile (Android/iOS) check authentication and show appropriate screen
        if (!kIsWeb) {
          Widget homeScreen;

          if (!authProvider.isAuthenticated) {
            homeScreen = const LoginScreen();
          } else if (authProvider.userType == 'enterprise') {
            // Enterprise users
            homeScreen = const EnterpriseMainScreen();
          } else {
            // Student users
            homeScreen = const MainScreen();
          }

          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'PFE Match',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              useMaterial3: true,
            ),
            home: homeScreen,
            onGenerateRoute: _generateRoute,
          );
        }

        // For web, keep the routed app (auth + web flows)
        return MaterialApp(
          navigatorKey: navigatorKey,
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
        // Home route will determine which screen to show based on user type
        page = Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.userType == 'enterprise') {
              return const EnterpriseMainScreen();
            }
            return const MainScreen();
          },
        );
        break;
      case '/create-student-profile':
        page = const CreateProfileScreen();
        break;
      case '/edit-student-profile':
        page = const EditStudentProfileScreen();
        break;
      case '/create-enterprise-profile':
        page = const CreateEnterpriseProfileScreen();
        break;
      default:
        page = const LoginScreen();
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
