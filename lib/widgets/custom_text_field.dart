import 'package:flutter/material.dart';
// Removed import of app_constants.dart

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // borderRadius
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // borderRadius
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // borderRadius
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2), // primaryColor
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // borderRadius
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 2), // errorColor
        ),
      ),
    );
  }
}