// ignore_for_file: use_build_context_synchronously

import 'package:chatr/screens/auth/sign_in/sign_in.dart';
import 'package:chatr/utils/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance
      .signOut()
      .then((value) {
        TokenStorage.clearToken();
        // بعد تسجيل الخروج، إعادة التوجيه إلى شاشة تسجيل الدخول
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logged out successfully")),
        );
      })
      .catchError((error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error logging out: $error")));
      });
}
