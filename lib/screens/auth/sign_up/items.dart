import 'package:flutter/material.dart';

Widget buildNameField({required TextEditingController nameController}) {
  return TextFormField(
    controller: nameController,
    keyboardType: TextInputType.name,
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.person),
      labelText: "Full Name",
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return "Name is required";
      if (value.length < 3) return "Name must be at least 3 characters";
      return null;
    },
  );
}

Widget buildConfirmPasswordField({
  required TextEditingController confirmController,
  required TextEditingController passwordController,
  required bool obscurePassword,
  required VoidCallback toggleObscurePassword,
}) {
  return TextFormField(
    controller: confirmController,
    obscureText: obscurePassword,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.lock_outline),
      labelText: "Confirm Password",
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
        onPressed: toggleObscurePassword,
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return "Confirm your password";
      if (value != passwordController.text) return "Passwords do not match";
      return null;
    },
  );
}
