// ignore_for_file: use_build_context_synchronously, invalid_return_type_for_catch_error

import 'dart:developer';
import 'package:chatr/screens/home/home.dart';
import 'package:chatr/utils/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> submit({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required String emailAddress,
  required String password,
  required String name,
}) async {
  if (formKey.currentState!.validate()) {
    await signUpWithEmailANdPassword(
      emailAddress: emailAddress,
      password: password,
      name: name,
      context: context,
    );
  }
}

Future signUpWithEmailANdPassword({
  required String emailAddress,
  required String password,
  required BuildContext context,
  required String name,
}) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: emailAddress, password: password)
        .then((value) async {
          await addUserToDatabase(
            name: name,
            email: emailAddress,
            uid: value.user!.uid,
            context: context,
          ).then((e) {
            TokenStorage.saveToken(value.user!.uid);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Sign Up Successful")),
            );
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
          });
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

Future<void> addUserToDatabase({
  required String name,
  required String email,
  required String uid,
  required BuildContext context,
}) async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  return users
      .doc(uid) // 🔹 نخلي doc هو الـ uid
      .set({
        'name': name.trim().toLowerCase(),
        'uid': uid,
        'email': email,
      }, SetOptions(merge: true)) // merge عشان ما يضيعش البيانات القديمة
      .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ User Added to Database")),
        );
      })
      .catchError((error) {
        debugPrint("❌ Failed to add user: $error");
      });
}
