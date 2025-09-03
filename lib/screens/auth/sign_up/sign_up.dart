import 'package:chatr/screens/auth/sign_up/functions.dart';
import 'package:chatr/screens/auth/sign_up/items.dart';
import 'package:chatr/screens/auth/widgets.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool isLoading = false;

  bool obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void toggleObscure() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6D83F2), Color(0xff4DA0B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Fields
                        buildNameField(nameController: _nameController),
                        const SizedBox(height: 16),
                        buildEmailField(emailController: _emailController),
                        const SizedBox(height: 16),
                        buildPasswordField(
                          passwordController: _passwordController,
                          obscurePassword: obscurePassword,
                          toggleObscurePassword: toggleObscure,
                        ),
                        const SizedBox(height: 16),
                        buildConfirmPasswordField(
                          confirmController: _confirmController,
                          passwordController: _passwordController,
                          obscurePassword: obscurePassword,
                          toggleObscurePassword: toggleObscure,
                        ),
                        const SizedBox(height: 24),

                        // Button
                        isLoading
                            ? const CircularProgressIndicator()
                            : buildButtons(
                                isSignUp: true,
                                submit: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  submit(
                                    context: context,
                                    formKey: _formKey,
                                    emailAddress: _emailController.text,
                                    password: _passwordController.text,
                                  ).then((_) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                },
                                context: context,
                                formKey: _formKey,
                              ),
                        const SizedBox(height: 12),

                        // Bottom Text
                        buildBottomSection(
                          isSignUp: true,
                          goTo: () {
                            Navigator.pop(context); // بيرجع لصفحة تسجيل الدخول
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
