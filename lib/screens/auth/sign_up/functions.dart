// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
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
    await signUpWithEmailANdPassword(
      emailAddress: emailAddress,
      password: password,
      context: context,
    );
  }
}

Future signUpWithEmailANdPassword({
  required String emailAddress,
  required String password,
  required BuildContext context,
}) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: emailAddress, password: password)
        .then((value) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("✅ Sign Up Successful")));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home()),
          );
          log('User signed in: ${value.user?.uid}');
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ Sign Up Failed: $error")));
        });
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      log('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      log('The account already exists for that email.');
    }
  } catch (e) {
    log(e.toString());
  }
}
