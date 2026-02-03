import 'package:flutter/material.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();

      if (auth.userType == 'enterprise') {
        Navigator.pushReplacementNamed(context, '/edit-enterprise-profile');
      } else if (auth.userType == 'student') {
        Navigator.pushReplacementNamed(context, '/edit-student-profile');
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
