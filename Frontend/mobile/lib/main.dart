import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'core/config/routes.dart';
import 'Screens/auth/login_screen.dart';
import 'Screens/auth/register_screen.dart';
import 'Screens/Student/create_profile_screen.dart';
import 'Screens/Student/profile_screen.dart';
// import 'Screens/Student/edit_profile_screen.dart';
// import 'Screens/Enterprise/create_profile_screen.dart';
// import 'Screens/Enterprise/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PFE Match',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.createStudentProfile: (context) =>
            const CreateProfileScreen(),
        AppRoutes.studentProfile: (context) => const StudentProfileScreen(),
        // AppRoutes.editStudentProfile: (context) => const EditProfileScreen(),
        // AppRoutes.createEnterpriseProfile: (context) => const CreateEnterpriseProfileScreen(),
        // AppRoutes.enterpriseProfile: (context) => const EnterpriseProfileScreen(),
      },
    );
  }
}
