import 'package:flutter/material.dart';

Widget buildEmailField({required TextEditingController emailController}) {
  return TextFormField(
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.email),
      labelText: "Email",
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return "Email is required";
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
      if (!emailRegex.hasMatch(value)) return "Enter a valid email";
      return null;
    },
  );
}

// 🟢 Section 2: Password Field
Widget buildPasswordField({
  required TextEditingController passwordController,
  required bool obscurePassword,
  required VoidCallback toggleObscurePassword,
}) {
  return TextFormField(
    controller: passwordController,
    obscureText: obscurePassword,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.lock),
      labelText: "Password",
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
        onPressed: toggleObscurePassword,
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return "Password is required";
      if (value.length < 6) return "Password must be at least 6 characters";
      return null;
    },
  );
}

Widget buildBottomSection({required VoidCallback goTo, bool isSignUp = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(isSignUp ? "Already have an account? " : "Don’t have an account? "),
      GestureDetector(
        onTap: goTo,
        child: Text(
          isSignUp ? "Sign In" : "Sign Up",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

Widget buildButtons({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required VoidCallback submit,
  bool isSignUp = false,
}) {
  return Column(
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: submit,
          child: Text(
            isSignUp ? "Sign Up" : "Login",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}
