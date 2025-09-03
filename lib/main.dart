import 'dart:developer';

import 'package:chatr/screens/auth/sign_in/sign_in.dart';
import 'package:chatr/screens/home/home.dart';
import 'package:chatr/utils/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String? token = await TokenStorage.getToken();
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    log(token.toString(), name: 'main');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatr',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: token != null ? const Home() : const SignInScreen(),
    );
  }
}
