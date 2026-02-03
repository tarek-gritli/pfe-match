import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Student/create_profile_screen.dart';
import '../Enterprise/create_profile_screen.dart';

Future<bool> checkType() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isStudent') ?? false;
}

@override
Widget build(BuildContext context) {
  return FutureBuilder<bool>(
    future: checkType(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return snapshot.data!
          ? const CreateStudentProfileScreen()
          : const CreateCompanyProfileScreen();
    },
  );
}