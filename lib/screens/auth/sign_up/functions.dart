import 'package:flutter/material.dart';

void submit({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
}) {
  if (formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Account Created Successfully")),
    );
  }
}
