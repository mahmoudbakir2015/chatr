import 'package:chatr/screens/auth/sign_up/sign_up.dart';
import 'package:flutter/material.dart';

void submit({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
}) {
  if (formKey.currentState!.validate()) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ Logged in successfully")));
  }
}

void goToSignUp({required BuildContext context}) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text("👉 Go to Sign Up Page")));
}
