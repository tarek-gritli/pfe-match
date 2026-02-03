import 'package:flutter/material.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();

      if (auth.userType == 'enterprise') {
        Navigator.pushReplacementNamed(context, '/create-enterprise-profile');
      } else if (auth.userType == 'student') {
        Navigator.pushReplacementNamed(context, '/create-student-profile');
      } else {
        // fallback
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
