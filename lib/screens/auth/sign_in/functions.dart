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
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text("👉 Go to Sign Up Page")));
}
