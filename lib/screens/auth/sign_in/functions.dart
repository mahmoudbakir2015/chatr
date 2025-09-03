// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:chatr/screens/auth/sign_up/sign_up.dart';
import 'package:chatr/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> submit({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required String emailAddress,
  required String password,
}) async {
  if (formKey.currentState!.validate()) {
    await signInWithEmailAndPassword(
      context: context,
      emailAddress: emailAddress,
      password: password,
    );
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

Future<void> signInWithEmailAndPassword({
  required BuildContext context,
  required String emailAddress,
  required String password,
}) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailAddress, password: password)
        .then((value) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("✅ Login Successful")));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Home(token: value.user!.uid),
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ Login Failed: $error")));
        });
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ No user found for that email.")),
      );
      log('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Wrong password provided for that user."),
        ),
      );

      log('Wrong password provided for that user.');
    }
  }
}
